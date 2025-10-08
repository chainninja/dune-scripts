# Repository Guidelines

## Project Structure & Module Organization
The repository is split between on-chain code under `contracts/` and analytics assets in `queries/`. The Solidity entry point is `contracts/WorldLibertyFinancialV2.sol`, which relies on OpenZeppelin upgradeable libraries expected at `contracts/libraries/oz-v5/...`; ensure that vendor tree is available before compiling. Dune Analytics SQL lives in `queries/`, with localized documentation and dashboards inside `queries/币安人生/`. Keep new SQL assets grouped by network or use-case, and pair them with a short README when workflows differ from the existing BSC holder guides.

## Build, Test, and Development Commands
Compile or lint Solidity with your Foundry toolchain: `forge build --contracts contracts` checks for syntax errors and missing imports, while `forge fmt` keeps spacing consistent. If you prefer Hardhat, target the same compiler version (`0.8.24`) and add the `contracts/libraries` path to `solc` includes. SQL changes should be validated directly in Dune; follow the workflow documented in `queries/BSC_TOKEN_HOLDER_README.md` and run each query through the “Run” preview before committing.

## Coding Style & Naming Conventions
Solidity files use four-space indentation, `CapWords` for contracts, `camelCase` for functions, and `UPPER_SNAKE_CASE` for constants (see `MAX_VOTING_POWER`). Namespace imports through explicit paths rather than relative `../` hops to avoid ambiguity in upgradeable deployments. SQL files treat keywords in uppercase, tables/CTEs in `snake_case`, and include inline comments only where logic deviates from standard ERC20 analytics. Preserve existing ASCII art banners and bilingual documentation; add localized content only when accompanied by an English summary.

## Testing Guidelines
Solidity features should ship with Foundry tests under a new `test/` directory—cover guardian controls, pause flows, and signature validation edge cases. Execute `forge test` locally and attach failure reproduction steps to PRs. When introducing SQL, capture sample outputs via Dune screenshots or dashboards and verify key aggregations (holder counts, supply percentages) against on-chain explorers such as BscScan before publishing updates.

## Commit & Pull Request Guidelines
The project’s Git history is currently inaccessible from this environment (macOS requires the Xcode license to be accepted), so default to concise, imperative commit subjects (for example, `docs: add wlfi guardian notes`) and explain the “why” in the body when behavior changes. PRs should summarize contract or query impacts, link to any related dashboards or issue trackers, and include before/after visuals or transaction hashes when applicable. Request a security-focused review whenever modifying guardian, pausing, or vesting logic.
