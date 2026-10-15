# Family Quiz Night (tvOS) – SE4041 MADD Assignment 02, Part B

**Student:** Asan M A M · **ID:** IT22253262

A living-room quiz game for 2–4 players sharing one Siri Remote. Players take turns
("hot seat"), race a 15-second timer, and earn speed bonuses. The winner gets a podium finish.

## Build & run
Open `asantvos.xcodeproj` in Xcode 26+, choose an **Apple TV 4K** simulator, press ⌘R.
Simulator controls: arrow keys = swipe, Return = click, Esc = Back (or Window ▸ Show Apple TV Remote).

## Highlights
| Area | Implementation |
|---|---|
| Multi-user | Turn rotation, per-player avatar/colour, live scoreboard with sliding highlight |
| tvOS interaction | Focus engine, `.card` button style (lift + parallax), `@FocusState` auto-focus, Back button (`onExitCommand`) |
| Architecture | MVVM: `QuizGame` @Observable engine (no UI code), `NavigationStack` routing with typed `Route` |
| Animation | Animated `MeshGradient` background, matched-geometry turn highlight, numeric score transitions, shake effect, podium rise |
| Testing | Swift Testing: turns, scoring, timeouts, draws, question bank · XCUITest with `XCUIRemote` |
