// Shared state and one bar per display.
import Quickshell

ShellRoot {
    ShellState {
        id: shellState
    }

    Variants {
        model: Quickshell.screens

        BarWindow {
            controller: shellState
        }
    }
}
