import QtQuick
import Quickshell.Io
import qs.Commons
import qs.Ui

// Screensaver settings panel: availability toggle, idle timings, a picker
// limiting which ttfx effects the random rotation uses, and branding actions.
// Pinned effects are honored by the omarchy-screensaver override in
// /usr/local/bin, which reads them back out of this widget's shell.json entry.
Panel {
  id: root
  moduleName: "brianirish.screensaver"
  ipcTarget: "brianirish.screensaver"

  property bool screensaverEnabled: true
  property int screensaverSeconds: 150
  property int lockSeconds: 300
  property int liveScreensaverSeconds: screensaverSeconds
  property int liveLockSeconds: lockSeconds

  readonly property var effects: setting("effects", [])

  readonly property var effectOptions: [
    { value: "beams", label: "Beams", description: "Beams travel over the canvas illuminating characters" },
    { value: "binarypath", label: "Binary Path", description: "Binary representations move toward each character's home" },
    { value: "blackhole", label: "Black Hole", description: "Characters consumed by a black hole, then explode outward" },
    { value: "bouncyballs", label: "Bouncy Balls", description: "Characters fall as bouncy balls from the top" },
    { value: "bubbles", label: "Bubbles", description: "Characters form bubbles that float down and pop" },
    { value: "burn", label: "Burn", description: "Burns vertically up the canvas" },
    { value: "colorshift", label: "Color Shift", description: "A gradient shifts colors across the terminal" },
    { value: "crumble", label: "Crumble", description: "Characters crumble to dust, get vacuumed up, reform" },
    { value: "decrypt", label: "Decrypt", description: "Movie-style decryption effect" },
    { value: "errorcorrect", label: "Error Correct", description: "Misplaced characters get corrected in sequence" },
    { value: "expand", label: "Expand", description: "Text expands from a single point" },
    { value: "fireworks", label: "Fireworks", description: "Characters launch, explode, and fall into place" },
    { value: "highlight", label: "Highlight", description: "A specular highlight runs across the text" },
    { value: "laseretch", label: "Laser Etch", description: "A laser etches characters onto the terminal" },
    { value: "matrix", label: "Matrix", description: "Matrix digital rain" },
    { value: "middleout", label: "Middle Out", description: "Text expands from the middle row/column outward" },
    { value: "orbittingvolley", label: "Orbiting Volley", description: "Orbiting launchers fire characters inward" },
    { value: "overflow", label: "Overflow", description: "Text overflows and scrolls until it appears ordered" },
    { value: "pour", label: "Pour", description: "Characters pour into position from one direction" },
    { value: "print", label: "Print", description: "Lines printed one at a time by a print head" },
    { value: "rain", label: "Rain", description: "Characters rain from the top of the canvas" },
    { value: "randomsequence", label: "Random Sequence", description: "Input printed in a random sequence" },
    { value: "rings", label: "Rings", description: "Characters disperse into spinning rings" },
    { value: "scattered", label: "Scattered", description: "Text scatters, then moves into position" },
    { value: "slice", label: "Slice", description: "Input slices in half and slides together" },
    { value: "slide", label: "Slide", description: "Characters slide in from outside the terminal" },
    { value: "smoke", label: "Smoke", description: "Smoke floods the canvas colorizing characters" },
    { value: "spotlights", label: "Spotlights", description: "Spotlights search the text, converge, and expand" },
    { value: "spray", label: "Spray", description: "Characters spawn at varying rates from a single point" },
    { value: "swarm", label: "Swarm", description: "Character swarms roam before settling into place" },
    { value: "sweep", label: "Sweep", description: "A sweep reveals uncolored text, a reverse sweep colors it" },
    { value: "synthgrid", label: "Synth Grid", description: "A grid fills with characters dissolving into the text" },
    { value: "thunderstorm", label: "Thunderstorm", description: "A thunderstorm in the terminal" },
    { value: "unstable", label: "Unstable", description: "Characters explode to the edges, then reassemble" },
    { value: "vhstape", label: "VHS Tape", description: "Lines glitch and lose detail like an old VHS tape" },
    { value: "waves", label: "Waves", description: "Waves travel across, leaving characters behind" },
    { value: "wipe", label: "Wipe", description: "A wipe across the terminal reveals characters" }
  ]

  readonly property string statusText: {
    if (!screensaverEnabled) return "DISABLED"
    if (effects.length === 1) return "1 EFFECT PINNED"
    if (effects.length > 0) return effects.length + " OF " + effectOptions.length + " EFFECTS"
    return "ALL EFFECTS · RANDOM"
  }

  function fmtSeconds(s) {
    if (s < 60) return s + "s"
    var m = Math.floor(s / 60)
    var r = s % 60
    return r === 0 ? m + "m" : m + "m " + r + "s"
  }

  function refresh() {
    enabledProc.running = true
    idleProc.running = true
  }

  function saveEffects(vals) {
    root.settings = Object.assign({}, root.settings, { effects: vals })
    if (root.bar && root.bar.shell) root.bar.shell.updateEntryInline(root.moduleName, root.settings)
  }

  function saveIdle(key, value) {
    if (key !== "screensaver" && key !== "lock") return
    var v = Math.max(0, Math.round(Number(value)))
    if (!isFinite(v)) return
    var script = 'f="$HOME/.config/omarchy/shell.json"; tmp="$f.tmp.$$"; ' +
      "jq --argjson v " + v + " '.idle." + key + ' = $v\' "$f" > "$tmp" && mv "$tmp" "$f"'
    idleWriteProc.command = ["bash", "-c", script]
    idleWriteProc.running = true
  }

  onOpenedChanged: if (opened) refresh()

  visible: true
  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  // Exit code 0 means the screensaver-off flag file exists.
  Process {
    id: enabledProc
    command: ["omarchy-toggle-enabled", "screensaver-off"]
    onExited: function(exitCode, exitStatus) { root.screensaverEnabled = exitCode !== 0 }
  }

  Process {
    id: idleProc
    command: ["bash", "-c", "jq -c '.idle // {}' \"$HOME/.config/omarchy/shell.json\" 2>/dev/null || echo '{}'"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        var idle = {}
        try { idle = JSON.parse(text) } catch (e) {}
        root.screensaverSeconds = typeof idle.screensaver === "number" ? idle.screensaver : 150
        root.lockSeconds = typeof idle.lock === "number" ? idle.lock : 300
        root.liveScreensaverSeconds = root.screensaverSeconds
        root.liveLockSeconds = root.lockSeconds
      }
    }
  }

  Process {
    id: toggleProc
    command: ["omarchy-toggle-screensaver"]
    onExited: root.refresh()
  }

  Process {
    id: idleWriteProc
    onExited: root.refresh()
  }

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: "󱄄"
    slotSize: Style.bar.iconSlot
    tooltipText: root.opened ? "" : "Screensaver"
    onPressed: function(b) {
      if (b === Qt.RightButton) toggleProc.running = true
      else root.toggle()
    }
  }

  KeyboardPanel {
    id: panel
    anchorItem: button
    owner: root
    bar: root.bar
    open: root.opened
    focusTarget: keyCatcher
    contentWidth: panel.fittedContentWidth(Style.space(380))
    contentHeight: panel.fittedContentHeight(column.implicitHeight)

    PanelKeyCatcher {
      id: keyCatcher
      anchors.fill: parent
      onCloseRequested: root.close()
      onTabRequested: function(direction) { root.switchPanel(direction) }

      Column {
        id: column
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        spacing: Style.space(14)

        // ---------- Hero: icon · title/status · preview ----------
        Item {
          width: parent.width
          implicitHeight: Math.max(heroIcon.implicitHeight, heroLabels.implicitHeight)

          Text {

            textFormat: Text.PlainText
            id: heroIcon
            text: "󱄄"
            color: root.bar.foreground
            font.family: root.bar.fontFamily
            font.pixelSize: Style.font.display
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
          }

          Column {
            id: heroLabels
            anchors.left: heroIcon.right
            anchors.leftMargin: Style.space(14)
            anchors.right: previewButton.left
            anchors.rightMargin: Style.space(10)
            anchors.verticalCenter: parent.verticalCenter
            spacing: Style.space(2)

            Text {

              textFormat: Text.PlainText
              text: "Screensaver"
              color: root.bar.foreground
              font.family: root.bar.fontFamily
              font.pixelSize: Style.font.title
              font.bold: true
              elide: Text.ElideRight
              width: parent.width
            }

            Text {

              textFormat: Text.PlainText
              text: root.statusText
              color: Qt.darker(root.bar.foreground, 1.4)
              font.family: root.bar.fontFamily
              font.pixelSize: Style.font.caption
              font.bold: true
              font.letterSpacing: 1.2
              elide: Text.ElideRight
              width: parent.width
            }
          }

          Button {
            id: previewButton
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            iconText: ""
            text: "Preview"
            fontSize: Style.font.bodySmall
            foreground: root.bar.foreground
            fontFamily: root.bar.fontFamily
            bordered: true
            horizontalPadding: Style.spacing.controlPaddingX
            verticalPadding: Style.spacing.controlPaddingY
            onClicked: {
              root.close()
              root.bar.run("omarchy-launch-screensaver force")
            }
          }
        }

        Toggle {
          width: parent.width
          label: "Enabled"
          description: "Start the screensaver when the system idles"
          checked: root.screensaverEnabled
          foreground: root.bar.foreground
          fontFamily: root.bar.fontFamily
          onClicked: toggleProc.running = true
        }

        PanelSeparator { foreground: root.bar.foreground }

        // ---------- Idle timing ----------
        Column {
          width: parent.width
          spacing: Style.space(10)

          PanelSectionHeader {
            text: "IDLE TIMING"
            foreground: root.bar.foreground
            fontFamily: root.bar.fontFamily
          }

          TimingRow {
            label: "Screensaver after"
            valueText: root.fmtSeconds(root.liveScreensaverSeconds)
            stops: [30, 60, 90, 120, 150, 180, 240, 300, 420, 600, 900, 1200, 1800]
            value: root.screensaverSeconds
            onMovedTo: function(v) { root.liveScreensaverSeconds = v }
            onCommitted: function(v) {
              root.liveScreensaverSeconds = v
              root.saveIdle("screensaver", v)
            }
          }

          TimingRow {
            label: "Lock after"
            valueText: root.fmtSeconds(root.liveLockSeconds)
            stops: [60, 120, 180, 300, 600, 900, 1200, 1800, 2700, 3600]
            value: root.lockSeconds
            onMovedTo: function(v) { root.liveLockSeconds = v }
            onCommitted: function(v) {
              root.liveLockSeconds = v
              root.saveIdle("lock", v)
            }
          }
        }

        PanelSeparator { foreground: root.bar.foreground }

        // ---------- Effects ----------
        Column {
          width: parent.width
          spacing: Style.space(10)

          PanelSectionHeader {
            text: "EFFECTS"
            foreground: root.bar.foreground
            fontFamily: root.bar.fontFamily
          }

          MultiSelect {
            id: effectSelect
            width: parent.width
            showLabel: false
            options: root.effectOptions
            values: root.effects
            placeholderText: "Search effects..."
            noSelectionText: "All effects (random)"
            fontFamily: root.bar.fontFamily
            onChanged: function(vals) { root.saveEffects(vals) }
          }

          Row {
            id: effectActions
            width: parent.width
            spacing: Style.space(6)

            readonly property real cellWidth: (width - spacing) / 2

            Button {
              width: effectActions.cellWidth
              text: "Select all"
              fontSize: Style.font.bodySmall
              foreground: root.bar.foreground
              fontFamily: root.bar.fontFamily
              bordered: true
              horizontalPadding: Style.spacing.controlPaddingX
              verticalPadding: Style.spacing.controlPaddingY
              onClicked: {
                var all = root.effectOptions.map(function(o) { return o.value })
                effectSelect.values = all
                root.saveEffects(all)
              }
            }

            Button {
              width: effectActions.cellWidth
              text: "Clear"
              fontSize: Style.font.bodySmall
              foreground: root.bar.foreground
              fontFamily: root.bar.fontFamily
              bordered: true
              horizontalPadding: Style.spacing.controlPaddingX
              verticalPadding: Style.spacing.controlPaddingY
              onClicked: {
                effectSelect.values = []
                root.saveEffects([])
              }
            }
          }

          Text {

            textFormat: Text.PlainText
            width: parent.width
            text: "Pick which effects the random rotation may use. None selected means all of them."
            color: root.bar.foreground
            opacity: 0.6
            font.family: root.bar.fontFamily
            font.pixelSize: Style.font.caption
            wrapMode: Text.WordWrap
          }
        }

        PanelSeparator { foreground: root.bar.foreground }

        // ---------- Branding ----------
        Column {
          width: parent.width
          spacing: Style.space(10)

          PanelSectionHeader {
            text: "ARTWORK"
            foreground: root.bar.foreground
            fontFamily: root.bar.fontFamily
          }

          Row {
            id: brandingRow
            width: parent.width
            spacing: Style.space(6)

            readonly property real cellWidth: (width - spacing * 2) / 3

            BrandingButton {
              iconText: ""
              text: "Edit text"
              command: "omarchy-branding-screensaver text"
            }
            BrandingButton {
              iconText: ""
              text: "From image"
              command: "omarchy-branding-screensaver image"
            }
            BrandingButton {
              iconText: ""
              text: "Reset"
              command: "omarchy-branding-screensaver reset"
            }
          }

          Text {

            textFormat: Text.PlainText
            width: parent.width
            text: "Text opens the ASCII art in your editor; image converts a PNG/SVG. Either way the result previews immediately."
            color: root.bar.foreground
            opacity: 0.6
            font.family: root.bar.fontFamily
            font.pixelSize: Style.font.caption
            wrapMode: Text.WordWrap
          }
        }
      }
    }
  }

  component TimingRow: Column {
    id: timingRow
    property string label: ""
    property string valueText: ""
    property var stops: []
    property real value: 0
    signal movedTo(real value)
    signal committed(real value)

    function nearestIndex(v) {
      var best = 0
      for (var i = 1; i < stops.length; i++) {
        if (Math.abs(stops[i] - v) < Math.abs(stops[best] - v)) best = i
      }
      return best
    }

    function stopAt(i) {
      var idx = Math.max(0, Math.min(stops.length - 1, Math.round(i)))
      return stops[idx]
    }

    width: parent.width
    spacing: Style.space(4)

    Item {
      width: parent.width
      implicitHeight: Math.max(rowLabel.implicitHeight, rowValue.implicitHeight)

      Text {

        textFormat: Text.PlainText
        id: rowLabel
        text: timingRow.label
        color: root.bar.foreground
        opacity: 0.8
        font.family: root.bar.fontFamily
        font.pixelSize: Style.font.bodySmall
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
      }

      Text {

        textFormat: Text.PlainText
        id: rowValue
        text: timingRow.valueText
        color: root.bar.foreground
        font.family: root.bar.fontFamily
        font.pixelSize: Style.font.bodySmall
        font.bold: true
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
      }
    }

    PanelSlider {
      width: parent.width
      bar: root.bar
      minimum: 0
      maximum: Math.max(0, timingRow.stops.length - 1)
      step: 1
      integer: true
      tickCount: timingRow.stops.length
      value: timingRow.nearestIndex(timingRow.value)
      onMoved: function(i) { timingRow.movedTo(timingRow.stopAt(i)) }
      onReleased: function(i) { timingRow.committed(timingRow.stopAt(i)) }
    }
  }

  component BrandingButton: Button {
    property string command: ""
    width: brandingRow.cellWidth
    fontSize: Style.font.bodySmall
    foreground: root.bar.foreground
    fontFamily: root.bar.fontFamily
    bordered: true
    horizontalPadding: Style.spacing.controlPaddingX
    verticalPadding: Style.spacing.controlPaddingY
    onClicked: {
      root.close()
      root.bar.run(command)
    }
  }
}
