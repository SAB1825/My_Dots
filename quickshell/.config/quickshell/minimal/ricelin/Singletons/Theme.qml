pragma Singleton
import QtQuick
import Quickshell
import "../../" as Shell

// Ricelin design tokens follow the shell palette, including live theme changes.
Singleton {
    readonly property bool dyn: false

    /**
     * The dynamic branch uses Dyn.primary because matugen's on-primary-container does not populate here and collapses the token to black.
     */
    readonly property color onGlow: Shell.Theme.glow

    readonly property color verm: Shell.Theme.accent
    readonly property color vermLit: Shell.Theme.accent
    readonly property color vermDeep: Qt.darker(Shell.Theme.accent, 1.2)
    readonly property color cream: Shell.Theme.text
    readonly property color bright: Shell.Theme.text
    readonly property color dim: Shell.Theme.muted
    readonly property color cardTop: Shell.Theme.surface
    readonly property color cardBot: Shell.Theme.background
    readonly property color border: Shell.Theme.hover
    readonly property color shadow: Qt.rgba(0, 0, 0, 0.55)
    readonly property color tileBg: Shell.Theme.background
    readonly property color subtle: Shell.Theme.muted
    readonly property color faint: Shell.Theme.muted
    readonly property color iconDim: Shell.Theme.text
    readonly property color hair: Qt.alpha(cream, 0.13)
    readonly property color hairSoft: Qt.alpha(cream, 0.08)
    readonly property color sheen: Qt.alpha(cream, 0.07)
    readonly property color danger: Shell.Theme.accent

    /**
     * Readable faint text (4.5:1 on the cards); faint itself stays for strokes and dividers.
     */
    readonly property color textFaint: Shell.Theme.muted
    readonly property color accentFill: Shell.Theme.accent
    readonly property color onAccent: Shell.Theme.accentText

    /**
     * The one type, space and corner scale every surface draws from, in unscaled pixels.
     */
    readonly property var fs: ({
            label: 9,
            meta: 10.5,
            body: 12.5,
            title: 15,
            display: 30
        })
    readonly property var sp: ({
            xxs: 2,
            xs: 4,
            s: 8,
            m: 12,
            l: 16,
            xl: 20
        })
    readonly property var r: ({
            xs: 4,
            s: 7,
            m: 9,
            l: 13,
            full: 999
        })
    readonly property var inset: ({
            top: 15,
            side: 18,
            bottom: 14
        })
    readonly property real labelTracking: 1.4
    readonly property color pressBg: Qt.alpha(cream, 0.09)

    readonly property color vermDim: Qt.alpha(Shell.Theme.accent, 0.55)
    readonly property color vermDimDeep: Qt.alpha(Shell.Theme.accent, 0.3)
    readonly property color vermBurn: Qt.darker(Shell.Theme.accent, 1.3)
    readonly property color tickRest: Shell.Theme.text
    readonly property color threadBg: Qt.alpha(cream, 0.13)
    readonly property color flameCore: Shell.Theme.text
    readonly property color flameGlow: Shell.Theme.glow

    /**
     * Literal hex strings because a color property serializes to #aarrggbb and corrupts the Canvas gradient, so no Qt.darker math here.
     */
    readonly property string flameInk: String(Shell.Theme.accent)
    readonly property string flameEmber: String(Shell.Theme.accent)
    readonly property string flameBurn: String(Shell.Theme.accent)
    readonly property string flameTip: String(Shell.Theme.glow)
    readonly property color todayWarm: Shell.Theme.accent
    readonly property color ghost: Shell.Theme.hover
    readonly property color frameBg: Shell.Theme.hover
    readonly property color frameBorder: Shell.Theme.hover
    readonly property color creamMenu: Qt.alpha(cream, 0.82)
    readonly property real shadowOpacity: 0.5
    /**
     * A snapshot and not a binding since Qt.fontFamilies() is not notifiable, so refreshFonts() runs once a dropped font's FontLoader is ready.
     */
    property var fontFamilies: Qt.fontFamilies()
    function refreshFonts() {
        fontFamilies = Qt.fontFamilies();
    }
    readonly property string font: Shell.Theme.font
    readonly property string fontJp: "Zen Kaku Gothic New"

    /**
     * MPRIS trackArtists is an array from some players and a plain string from others (Spotify), where join would throw and kill the binding.
     */
    function joinArtists(artists, single) {
        if (artists && typeof artists.join === "function" && artists.length > 0)
            return artists.join(", ");
        if (artists && String(artists).length > 0)
            return String(artists);
        return single ? String(single) : "";
    }
}
