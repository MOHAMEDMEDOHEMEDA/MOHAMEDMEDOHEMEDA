# Clean-Arch DI migration spec (per feature)

Apply the SAME pattern already proven on `Verification`. Read these reference files FIRST and mirror them exactly:

- `Binbon/Features/Verification/Domain/Repositories/VerificationRepositoryProtocol.swift`
- `Binbon/Features/Verification/Domain/UseCases/SubmitVerificationUseCase.swift`
- `Binbon/Features/Verification/Data/DataSources/VerificationRemoteDataSource.swift`
- `Binbon/Features/Verification/Data/Repositories/VerificationRepositoryImpl.swift`
- `Binbon/Features/Verification/DI/AppDIContainer+Verification.swift`
- `Binbon/Features/Verification/Presentation/ViewModel/VerificationViewModel.swift`

## For feature `F`, create under `Binbon/Features/<F>/`:

1. `Domain/Repositories/<F>RepositoryProtocol.swift` — `protocol`, methods `async throws -> <Entity>`. Returns REUSED app models as entities (never invent DTO/entity types). Throws `APIError`. NEVER expose `BaseResponse`.
2. `Domain/UseCases/<Verb>UseCase.swift` — `struct` with a REQUIRED injected `repository`, `func execute(...) async throws -> ...`. One use case per data operation. If several, group in one `<F>UseCases.swift`.
3. `Data/DataSources/<F>RemoteDataSource.swift` — `protocol <F>RemoteDataSource` + `struct Mock<F>RemoteDataSource: <F>RemoteDataSource`. MOVE the inline sample/mock data that currently lives in the VM's `load()` into the mock data source (private `static let mock` extensions like the reference).
4. `Data/Repositories/<F>RepositoryImpl.swift` — `final class <F>RepositoryImpl: <F>RepositoryProtocol`, holds `private let remote`, delegates to it.
5. `DI/AppDIContainer+<F>.swift` — `extension AppDIContainer` with `makeXRemoteDataSource() / makeXRepository() -> Protocol / makeXUseCase() / @MainActor makeXViewModel()` factories.

## Rewire the ViewModel(s):

- Add stored `private let <verb>UseCase: <Verb>UseCase` props.
- Add a DESIGNATED `init(<useCases>)` AND a `convenience init(container: AppDIContainer = .shared)` resolving each use case via `container.makeX()`. This is CRITICAL: existing call sites create the VM as `XViewModel()` — the convenience init's default container keeps that compiling.
- Replace inline mock loading with `try await useCase.execute()`. Drive the EXISTING state enum directly (`state = .loading` → `.loaded(data)` / `.failed(asAPIError(error))`). Wrap in `Task { }` if the method isn't async.
- NEVER use `isLoading=true; defer { isLoading=false }` — the defer clobbers a `.failed` set in catch. Drive the enum.
- Add `private func asAPIError(_ error: Error) -> APIError { (error as? APIError) ?? Network.shared.mapError(error) }` if mapping is needed.
- Navigation stays as routes (`router?.navigate(...)` / `AppRouter.shared`). Do NOT add Coordinator classes.

## Rules

- DELETE the feature's old `…Repo.swift` / `…RepoProtocol.swift` ONLY if it exists AND this feature is its sole consumer.
- Do NOT run `xcodebuild` (a central build runs after the batch). Do NOT edit `project.pbxproj` (file-system-synchronized groups auto-add files under `Binbon/`).
- Comments: concise, human, no AI tells. Match neighbouring code.
- If a VM has NO data operation (pure UI/form state), say so and create a minimal repo only if a load exists; otherwise skip and report.

## Setting-suite variant — wrapping the shared `SettingRepo` (chunking pattern)

Setting sub-features do NOT get their own RemoteDataSource. They WRAP the shared `SettingRepo` (do not modify or delete it). Reference the proven template:
- `Binbon/Features/Setting/LegalSettings/Domain/Repositories/LegalSettingsRepositoryProtocol.swift`
- `Binbon/Features/Setting/LegalSettings/Data/Repositories/LegalSettingsRepositoryImpl.swift`
- `Binbon/Features/Setting/LegalSettings/DI/AppDIContainer+LegalSettings.swift`

For Setting sub-feature `S` whose VM(s) currently hold `repo/settingRepo: SettingRepoProtocol = SettingRepo()`:
1. `Domain/Repositories/<S>RepositoryProtocol.swift` — one `async throws -> Entity` method per `SettingRepo` method the VM(s) actually call. Action endpoints returning `BaseResponse<EmptyResponse>` become `async throws` (Void) or `async throws -> Entity` for the payload-bearing ones.
2. `Data/Repositories/<S>RepositoryImpl.swift` — `final class <S>RepositoryImpl: <S>RepositoryProtocol`, holds `private let settingRepo: SettingRepoProtocol`, and for each method does the `switch await settingRepo.x() { case .success(let r): return r.data (guard non-nil, else throw APIError(type:.parsing,...)); case .failure(let e): throw e }` unwrap. For `BlockedUsersResponse` (returned NOT wrapped in BaseResponse) just return `r` on success.
3. `Domain/UseCases/<Verb>UseCase.swift` (group as `<S>UseCases.swift` if many) — struct, required injected `repository`, `execute(...)`.
4. `DI/AppDIContainer+<S>.swift` — `make<S>Repository() { <S>RepositoryImpl(settingRepo: makeSettingRepo()) }` (`makeSettingRepo()` already exists), `make…UseCase()` per use case, `@MainActor make<VM>()` per VM.
5. Rewire each VM: replace the `repo/settingRepo` property with injected use cases, designated `init(<useCases>)` + `convenience init(container: AppDIContainer = .shared)`. Replace `switch await repo.x()` call sites with `try await useCase.execute()` inside `do/catch`, driving the VM's existing `@Published` state / error. Keep all UI logic.

SPECIAL CASE — a VM holds `settingRepo` but only has COMMENTED-OUT usage (no active call): do NOT invent a repo/use case. Just keep the `settingRepo: SettingRepoProtocol` param but make it required and add `convenience init(container: AppDIContainer = .shared)` resolving `container.makeSettingRepo()`. Report it as "DI-only".
