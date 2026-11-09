import QtQuick
import Quickshell.Io
import qs.Commons
import qs.Ui
import "Model.js" as Model

// Screensaver settings panel: availability toggle, idle timings, a picker
// limiting which ttfx effects the random rotation uses, and branding actions.
// Pinned effects are honored by the two scripts in extras/, installed to
// /usr/local/bin: the omarchy-screensaver override for the terminal
// screensaver Omarchy 4.5.0 runs, and the omarchy-launch-screensaver wrapper
// for the native one that replaces it. Both read the pins back out of this
// widget's shell.json entry.
Panel {
  id: root
  moduleName: "brianirish.screensaver"
  ipcTarget: "brianirish.screensaver"

  Translations { id: strings; directory: Qt.resolvedUrl("i18n") }

  property bool screensaverEnabled: true
  property int screensaverSeconds: 150
  property int lockSeconds: 300
  property int liveScreensaverSeconds: screensaverSeconds
  property int liveLockSeconds: lockSeconds

  // Bindings, so a settings change or a language switch shows at once.
  readonly property var effects: Model.pinnedEffects(setting("effects", []))
  readonly property var effectOptions: Model.effectOptions(strings)
  readonly property string statusText:
    Model.status(screensaverEnabled, effects.length, effectOptions.length, strings, v => I18n.formatNumber(v))

  function duration(seconds) {
    return Model.duration(seconds, strings, v => I18n.formatNumber(v))
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
  // MultiSelect sets its own values when clicked, which ends the values
  // binding below; push the setting back in whenever it changes, so a change
  // made outside the panel (omarchy bar set, an edit to shell.json) shows.
  onEffectsChanged: effectSelect.values = root.effects

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
    tooltipText: root.opened ? "" : strings.t("title")
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
              text: strings.t("title")
              color: root.bar.foreground
              font.family: root.bar.fontFamily
              font.pixelSize: Style.font.title
              font.bold: true
              elide: Text.ElideRight
              width: parent.width
            }

            Text {

              textFormat: Text.PlainText
              text: root.statusText.toUpperCase()
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
            text: strings.t("preview")
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
          label: strings.t("enabled.label")
          description: strings.t("enabled.description")
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
            text: strings.t("section.idle")
            foreground: root.bar.foreground
            fontFamily: root.bar.fontFamily
          }

          TimingRow {
            label: strings.t("idle.screensaver")
            valueText: root.duration(root.liveScreensaverSeconds)
            stops: [30, 60, 90, 120, 150, 180, 240, 300, 420, 600, 900, 1200, 1800]
            value: root.screensaverSeconds
            onMovedTo: function(v) { root.liveScreensaverSeconds = v }
            onCommitted: function(v) {
              root.liveScreensaverSeconds = v
              root.saveIdle("screensaver", v)
            }
          }

          TimingRow {
            label: strings.t("idle.lock")
            valueText: root.duration(root.liveLockSeconds)
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
            text: strings.t("section.effects")
            foreground: root.bar.foreground
            fontFamily: root.bar.fontFamily
          }

          MultiSelect {
            id: effectSelect
            width: parent.width
            showLabel: false
            options: root.effectOptions
            values: root.effects
            placeholderText: strings.t("effects.search")
            noSelectionText: strings.t("effects.none")
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
              text: strings.t("effects.selectAll")
              fontSize: Style.font.bodySmall
              foreground: root.bar.foreground
              fontFamily: root.bar.fontFamily
              bordered: true
              horizontalPadding: Style.spacing.controlPaddingX
              verticalPadding: Style.spacing.controlPaddingY
              onClicked: root.saveEffects(root.effectOptions.map(function(o) { return o.value }))
            }

            Button {
              width: effectActions.cellWidth
              text: strings.t("effects.clear")
              fontSize: Style.font.bodySmall
              foreground: root.bar.foreground
              fontFamily: root.bar.fontFamily
              bordered: true
              horizontalPadding: Style.spacing.controlPaddingX
              verticalPadding: Style.spacing.controlPaddingY
              onClicked: root.saveEffects([])
            }
          }

          Text {

            textFormat: Text.PlainText
            width: parent.width
            text: strings.t("effects.help")
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
            text: strings.t("section.artwork")
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
              text: strings.t("artwork.text")
              command: "omarchy-branding-screensaver text"
            }
            BrandingButton {
              iconText: ""
              text: strings.t("artwork.image")
              command: "omarchy-branding-screensaver image"
            }
            BrandingButton {
              iconText: ""
              text: strings.t("artwork.reset")
              command: "omarchy-branding-screensaver reset"
            }
          }

          Text {

            textFormat: Text.PlainText
            width: parent.width
            text: strings.t("artwork.help")
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
