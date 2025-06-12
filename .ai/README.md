# AI Configuration and Instructions Directory (`.ai/`)

This directory contains all files related to configuring, instructing, and managing AI agent interactions with this repository.

## Structure Overview

- **`manifest.yaml`**: A machine-readable inventory of AI-related resources in this repository. This is the primary index.
- **`goals/`**: Contains documents outlining high-level project goals and specific objectives for AI involvement.
- **`rules/`**: Holds detailed guidelines, rules, coding standards, style guides, and AI persona definitions.
- **`knowledge-base/`**: Stores domain-specific information, architectural details, glossaries, and other contextual data to aid AI understanding.
- **`tasks/`**: Manages work items for AI assistance, categorized into `backlog/`, `doing/`, and `done/`.
- **`history/`**: Archives important decisions, AI-generated change logs, or significant past interactions.
- **`prompts/` (Optional)**: A collection of reusable prompt templates for common AI-driven tasks.

## How to Use
- **For Humans:** Familiarize yourself with this structure to effectively guide AI agents and manage their contributions. Review `knowledge-base/augment-code-user-guidelines.md` for comprehensive AI interaction guidelines.
- **For AI Agents:** Your primary entry point is usually the `AI_ROOT_GUIDE.md` in the project root. This directory provides the detailed context and rules referenced from there. Consult the `manifest.yaml` for a structured overview and `knowledge-base/augment-code-user-guidelines.md` for detailed interaction guidelines.