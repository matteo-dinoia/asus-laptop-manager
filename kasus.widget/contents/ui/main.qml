import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami

import org.kde.plasma.plasma5support as Plasma5Support

//TODO add setting to reduce fan/cpu at startup
//TODO power profile has isTlpInstalled property
// Add to file visudo  name hsost = (root) NOPASSWD: /usr/bin/auto-cpufreq
PlasmoidItem {
    id: root

    property int cpu: 1
    property int fan: 1
    property int gpu: 1

    property bool cpuLoaded: false
    property bool fanLoaded: false
    property bool gpuLoaded: false
    property bool loaded: cpuLoaded && fanLoaded && gpuLoaded

    //property string logs: ""
    property bool gpu_changed: false

    Component.onCompleted: {
        // TODO from settings
        if(true){
            fanLoaded = true
            runner.exec("asus fan 1")
        } else {
            runner.exec("asus status-id fan")
        }

        runner.exec("asus status-id cpu")
        runner.exec("asus status-id gpu")
    }

    function updateCpu(val){
        root.cpu = val
        if(!loaded) return;
        runner.exec("asus cpu " + val)
    }

    function updateFan(val){
        root.fan = val
        if(!loaded) return;
        runner.exec("asus fan " + val)
    }

    function updateGpu(val){
        root.gpu = val
        if(!loaded) return;
        gpu_changed = true
        runner.exec("asus gpu " + root.gpu)
    }

    property string statusIcon: {
        print(cpu + " "+  fan+ " " + gpu)
        if(!loaded)
            return "paint-unknown";
        else if(cpu == 1 && fan == 1 && gpu == 1)
            return "battery-profile-powersave"
        else
            return "battery-profile-performance"
    }

    compactRepresentation: MouseArea {
        Kirigami.Icon {
            source: statusIcon
            anchors.fill: parent
        }

        onClicked: {
            root.expanded = !root.expanded
        }
    }

    fullRepresentation: Item {
        Layout.minimumWidth: 300
        Layout.minimumHeight: 350

        ColumnLayout {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: Kirigami.Units.largeSpacing

            RowLayout {

                Kirigami.Icon {
                    Layout.alignment: Qt.AlignTop
                    Layout.preferredWidth: Kirigami.Units.iconSizes.medium
                    Layout.preferredHeight: Kirigami.Units.iconSizes.medium

                    source: "speedometer"
                }

                ColumnLayout {
                    Layout.fillWidth: true

                    Label {
                        text: "Cpu"
                    }
                    Slider {
                        id: sliderCpu
                        value: root.cpu
                        from: 1
                        to: 3
                        stepSize: 1
                        live: false
                        onValueChanged: updateCpu(value)
                        enabled: root.loaded
                        Layout.fillWidth: true
                    }
                    Label {

                        text: "Change auto-cpufrequency governor"

                        color: Kirigami.Theme.disabledTextColor
                        font: Kirigami.Theme.smallFont
                        wrapMode: Text.Wrap
                        Layout.fillWidth: true
                    }
                }
            }

            RowLayout {

                Kirigami.Icon {
                    Layout.alignment: Qt.AlignTop
                    Layout.preferredWidth: Kirigami.Units.iconSizes.medium
                    Layout.preferredHeight: Kirigami.Units.iconSizes.medium

                    source: "temperature-normal-symbolic"
                }

                ColumnLayout {
                    Layout.fillWidth: true

                    Label {
                        text: "Fan"
                    }
                    Slider {
                        id: sliderFan
                        value: root.fan
                        from: 1
                        to: 3
                        stepSize: 1
                        live: false
                        onValueChanged: updateFan(value)
                        enabled: root.loaded
                        Layout.fillWidth: true
                    }
                    Label {
                        text: "Change asusctl fan curve"

                        color: Kirigami.Theme.disabledTextColor
                        font: Kirigami.Theme.smallFont
                        wrapMode: Text.Wrap
                        Layout.fillWidth: true
                    }
                }
            }

            RowLayout {

                Kirigami.Icon {
                    Layout.alignment: Qt.AlignTop
                    Layout.preferredWidth: Kirigami.Units.iconSizes.medium
                    Layout.preferredHeight: Kirigami.Units.iconSizes.medium

                    source: "video-card-inactive"
                }

                ColumnLayout {
                    Layout.fillWidth: true

                    Label {
                        text: "Gpu" + (gpu_changed ? " (reboot now to see result)"
                                : " (status coming soon)")
                    }
                    RowLayout {
                        id: listGpu
                        Layout.fillWidth: true

                        Repeater {
                            model: ["Disabled", "Hybrid", "Dedicated"]
                            Button {
                                required property int index
                                required property string modelData

                                Layout.fillWidth: true
                                text: modelData
                                onClicked: updateGpu(index + 1)
                                enabled: root.loaded && index + 1 != gpu && !gpu_changed
                            }
                        }
                    }
                    Label {
                        text: "Change gpu used by system using supergfxctl"

                        color: Kirigami.Theme.disabledTextColor
                        font: Kirigami.Theme.smallFont
                        wrapMode: Text.Wrap
                        Layout.fillWidth: true
                    }
                }
            }

            /*Label{
                Layout.fillWidth: true
                text: logs
                color: Kirigami.Theme.disabledTextColor
                font: Kirigami.Theme.smallFont
                wrapMode: Text.Wrap
            }*/
        }
    }

    Plasma5Support.DataSource {
        id: runner
        engine: "executable"
        connectedSources: []
        onNewData: function(source, data) {
            if (data["exit code"] != 0) return;
            let output = data["stdout"]
            //logs += source + " -> " + output + " \n"

            if(source == "asus status-id cpu"){
                updateCpu(parseInt(output))
                root.cpuLoaded = true
            }else if(source == "asus status-id fan"){
                updateFan(parseInt(output))
                root.fanLoaded = true
            }else if(source == "asus status-id gpu"){
                updateGpu(parseInt(output))
                root.gpuLoaded = true
            }

            disconnectSource(source)
        }

        function exec(cmd) {
            runner.connectSource(cmd)
        }
    }
}
