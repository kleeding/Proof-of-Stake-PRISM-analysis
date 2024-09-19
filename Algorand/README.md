# Algorand-PRISM-analysis
This respository describes the formal analysis of the Algorand protocol using the probabilistic model checking tool PRISM.

Three models are described:
- A `/base.pm` model describing three agents performing the protocol honestly.
- A `/sybil.pm` model describing three agents in which the 3rd performs a Sybil strategy, splitting their stake between two new agents.
- A `/pooling.pm` model describing three agents in which the 2nd and 3rd perform a pooling strategy, merging their stake into a single agent.

These are analysed against a set of properties described in `/Proof-of-Stake-PRISM-analysis/Algorand/property.pctl`.

# Running models in PRISM
- Download and install PRISM: https://www.prismmodelchecker.org/download.php
- Open a model in the PRISM GUI
- Open the property file
- Verify or experiment with properties

For more information on using the PRISM tool please refer to the [PRISM manual](https://www.prismmodelchecker.org/manual/RunningPRISM/StartingPRISM).
