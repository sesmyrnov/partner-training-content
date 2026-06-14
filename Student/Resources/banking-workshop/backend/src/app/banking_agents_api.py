import logging
import os
import uuid
from langchain.schema import AIMessage
from typing import Literal
from langgraph.graph import StateGraph, START, MessagesState
from langgraph.prebuilt import create_react_agent
from langgraph.types import Command, interrupt
from langgraph.checkpoint.memory import MemorySaver
from src.app.services.azure_open_ai import model
from src.app.tools.coordinator import create_agent_transfer
from langgraph_checkpoint_cosmosdb import CosmosDBSaver
from src.app.services.azure_cosmos_db import (
    DATABASE_NAME,
    checkpoint_container,
    chat_container,
    update_chat_container,
    patch_active_agent,
)
from src.app.tools.sales import (
    calculate_monthly_payment,
    create_account,
    get_offer_information,
)
from src.app.tools.support import get_branch_location, service_request
from src.app.tools.transactions import (
    bank_balance,
    bank_transfer,
    get_transaction_history,
)

local_interactive_mode = False

logging.basicConfig(level=logging.ERROR)

PROMPT_DIR = os.path.join(os.path.dirname(__file__), "prompts")


# load prompts
def load_prompt(agent_name):
    """Loads the prompt for a given agent from a file."""
    file_path = os.path.join(PROMPT_DIR, f"{agent_name}.prompty")
    print(f"Loading prompt for {agent_name} from {file_path}")
    try:
        with open(file_path, "r", encoding="utf-8") as file:
            return file.read().strip()
    except FileNotFoundError:
        print(f"Prompt file not found for {agent_name}, using default placeholder.")
        return "You are an AI banking assistant."  # Fallback default prompt


# define agents & tools
coordinator_agent_tools = [
    create_agent_transfer(agent_name="transactions_agent"),
    create_agent_transfer(agent_name="sales_agent"),
    create_agent_transfer(agent_name="customer_support_agent"),
]

customer_support_agent_tools = [
    get_branch_location,
    service_request,
    create_agent_transfer(agent_name="sales_agent"),
    create_agent_transfer(agent_name="transactions_agent"),
]

customer_support_agent = create_react_agent(
    model,
    customer_support_agent_tools,
    state_modifier=load_prompt("customer_support_agent"),
)

coordinator_agent = create_react_agent(
    model,
    tools=coordinator_agent_tools,
    state_modifier=load_prompt("coordinator_agent"),
)

transactions_agent_tools = [
    bank_balance,
    bank_transfer,
    get_transaction_history,
    create_agent_transfer(agent_name="customer_support_agent"),
]

transactions_agent = create_react_agent(
    model,
    transactions_agent_tools,
    state_modifier=load_prompt("transactions_agent"),
)

sales_agent_tools = [
    get_offer_information,
    calculate_monthly_payment,
    create_account,
    #create_agent_transfer(agent_name="customer_support_agent"),
    create_agent_transfer(agent_name="transactions_agent"),
]

sales_agent = create_react_agent(
    model,
    sales_agent_tools,
    state_modifier=load_prompt("sales_agent"),
)


# define functions
def call_coordinator_agent(
    state: MessagesState, config
) -> Command[Literal["coordinator_agent", "human"]]:
    thread_id = config["configurable"].get("thread_id", "UNKNOWN_THREAD_ID")
    userId = config["configurable"].get("userId", "UNKNOWN_USER_ID")
    tenantId = config["configurable"].get("tenantId", "UNKNOWN_TENANT_ID")

    logging.debug(f"Calling coordinator agent with Thread ID: {thread_id}")

    # Get the active agent from Cosmos DB with a point lookup
    partition_key = [tenantId, userId, thread_id]
    activeAgent = None
    try:
        activeAgent = chat_container.read_item(
            item=thread_id, partition_key=partition_key
        ).get("activeAgent", "unknown")

    except Exception as e:
        logging.debug(f"No active agent found: {e}")

    if activeAgent is None:
        if local_interactive_mode:
            update_chat_container(
                {
                    "id": thread_id,
                    "tenantId": "Contoso",
                    "userId": "Mark",
                    "sessionId": thread_id,
                    "name": "cli-test",
                    "age": "cli-test",
                    "address": "cli-test",
                    "activeAgent": "unknown",
                    "ChatName": "cli-test",
                    "messages": [],
                }
            )

    logging.debug(f"Active agent from point lookup: {activeAgent}")

    # If active agent is something other than unknown or coordinator_agent, transfer directly to that agent

    if activeAgent is not None and activeAgent not in ["unknown", "coordinator_agent"]:
        print(f"[DEBUG] Previous agent was: {activeAgent} — re-evaluating intent")

    # ✅ ALWAYS evaluate intent
    user_text = state["messages"][-1].content.lower()

    print("\n🟡 [DEBUG] Coordinator analyzing:", user_text)

    if any(x in user_text for x in ["loan", "loans", "offer", "offers", "product", "credit", "savings"]):
        print("✅ Routing to SALES agent")
        return Command(update={"messages": state["messages"]}, goto="sales_agent")

    if any(x in user_text for x in ["balance", "transaction", "transfer"]):
        print("✅ Routing to TRANSACTIONS agent")
        return Command(goto="transactions_agent")

    print("✅ Routing to SUPPORT agent (fallback)")
    return Command(goto="customer_support_agent")

    print("\n🟡 [DEBUG] Coordinator analyzing:", user_text)

        # ✅ HARD ROUTING (no ambiguity)
    if any(x in user_text for x in ["loan", "loans", "offer", "product", "credit", "savings"]):
        print("✅ Routing to SALES agent")
        return Command(update={"messages": state["messages"]}, goto="sales_agent")

    if any(x in user_text for x in ["balance", "transaction", "transfer"]):
        print("✅ Routing to TRANSACTIONS agent")
        return Command(update=state, goto="transactions_agent")

    print("✅ Routing to SUPPORT agent (fallback)")
    return Command(update=state, goto="customer_support_agent")
        #response = coordinator_agent.invoke(state)
        #return Command(update=response, goto="human")


def call_customer_support_agent(
    state: MessagesState, config
) -> Command[Literal["customer_support_agent", "human"]]:
    thread_id = config["configurable"].get("thread_id", "UNKNOWN_THREAD_ID")
    if local_interactive_mode:
        patch_active_agent(
            tenantId="Contoso",
            userId="Mark",
            sessionId=thread_id,
            activeAgent="customer_support_agent"
        )
    else: 
        patch_active_agent(
        tenantId=config["configurable"].get("tenantId"),
        userId=config["configurable"].get("userId"),
        sessionId=thread_id,
        activeAgent="customer_support_agent"   # or respective agent
        )

    response = customer_support_agent.invoke(state)
    return Command(update=response, goto="human")


def call_sales_agent(
    state: MessagesState, config
) -> Command[Literal["sales_agent", "human"]]:
    thread_id = config["configurable"].get("thread_id", "UNKNOWN_THREAD_ID")
    if local_interactive_mode:
        patch_active_agent(
            tenantId="Contoso",
            userId="Mark",
            sessionId=thread_id,
            activeAgent="sales_agent"
            )
    else:        
        patch_active_agent(
            tenantId=config["configurable"].get("tenantId"),
            userId=config["configurable"].get("userId"),
            sessionId=thread_id,
            activeAgent="sales_agent"   # or respective agent
            )
    response = sales_agent.invoke(state, config)  # Invoke sales agent with state
    return Command(update=response, goto="human")


def call_transactions_agent(
    state: MessagesState, config
) -> Command[Literal["transactions_agent", "human"]]:
    thread_id = config["configurable"].get("thread_id", "UNKNOWN_THREAD_ID")
    if local_interactive_mode:
        patch_active_agent(
            tenantId="Contoso",
            userId="Mark",
            sessionId=thread_id,
            activeAgent="transactions_agent"
        )
    else:
        patch_active_agent(
            tenantId=config["configurable"].get("tenantId"),
            userId=config["configurable"].get("userId"),
            sessionId=thread_id,
            activeAgent="transactions_agent"   # or respective agent
        )
    response = transactions_agent.invoke(state)
    return Command(update=response, goto="human")


# The human_node with interrupt function serves as a mechanism to stop
# the graph and collect user input for multi-turn conversations.
def human_node(state: MessagesState, config) -> None:
    """A node for collecting user input."""
    interrupt(value="Ready for user input.")
    return None


# define workflow
builder = StateGraph(MessagesState)
builder.add_node("coordinator_agent", call_coordinator_agent)
builder.add_node("customer_support_agent", call_customer_support_agent)
builder.add_node("human", human_node)
builder.add_node("transactions_agent", call_transactions_agent)
builder.add_node("sales_agent", call_sales_agent)

builder.add_edge(START, "coordinator_agent")

checkpointer = CosmosDBSaver(
    database_name=DATABASE_NAME, container_name=checkpoint_container
)
graph = builder.compile(checkpointer=checkpointer)


def interactive_chat():
    thread_config = {
        "configurable": {
            "thread_id": str(uuid.uuid4()),
            "userId": "Mark",
            "tenantId": "Contoso",
        }
    }
    global local_interactive_mode
    local_interactive_mode = True
    print("Welcome to the single-agent banking assistant.")
    print("Type 'exit' to end the conversation.\n")

    user_input = input("You: ")
    conversation_turn = 1

    while user_input.lower() != "exit":

        input_message = {"messages": [{"role": "user", "content": user_input}]}

        response_found = False  # Track if we received an AI response

        for update in graph.stream(
            input_message,
            config=thread_config,
            stream_mode="updates",
        ):
            for node_id, value in update.items():
                if isinstance(value, dict) and value.get("messages"):
                    last_message = value["messages"][-1]  # Get last message
                    if isinstance(last_message, AIMessage):
                        print(f"{node_id}: {last_message.content}\n")
                        response_found = True

        if not response_found:
            print("DEBUG: No AI response received.")

        # Get user input for the next round
        user_input = input("You: ")
        conversation_turn += 1


if __name__ == "__main__":
    interactive_chat()
