import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami

import org.kde.plasma.components as PC
import org.kde.plasma.plasma5support as Plasma5Support

PlasmoidItem {
    id: root
    //preferredRepresentation: compactRepresentation

    property int cpu: 1
    property int fan: 1
    property int gpu: 1
    //property string logs: ""

    Component.onCompleted: {
        //TODO get in asus
        updateCpu(1)
        updateFan(1)
    }

    function updateCpu(val){
        root.cpu = val
        executable.exec("sudo asus cpu " + root.cpu)
    }

    function updateFan(val){
        root.fan = val
        executable.exec("asus fan " + root.fan)
    }

    function updateGpu(val){
        root.gpu = val
        executable.exec("asus gpu " + root.gpu)
    }


    property string statusIcon: cpu == 1 && fan == 1 && gpu == 1 ? "battery-profile-powersave" : "battery-profile-performance"

    compactRepresentation: MouseArea {
        onClicked: {
            root.expanded = !root.expanded
        }

        Kirigami.Icon {
            source: statusIcon
        }
    }

    fullRepresentation: Item{
        Layout.minimumWidth: 250
        Layout.minimumHeight: 200
        Rectangle{
            anchors.fill: parent
            anchors.margins: Kirigami.Units.largeSpacing
            color: "transparent"


            ColumnLayout {
                anchors.left: parent.left
                anchors.right: parent.right
                spacing: Kirigami.Units.largeSpacing

                PC.Label {
                    text: "Cpu"
                }
                Slider {
                    value: 1
                    from: 1
                    to: 3
                    stepSize: 1
                    live: false
                    onValueChanged: updateCpu(value)

                    Layout.fillWidth: true
                }

                PC.Label {
                    text: "Fan"
                }
                Slider {
                    value: 1
                    from: 1
                    to: 3
                    stepSize: 1
                    live: false
                    onValueChanged: updateFan(value)

                    Layout.fillWidth: true
                }

                PC.Label {
                    text: "Gpu"
                }
                RowLayout {
                    id: listGpu
                    Layout.fillWidth: true

                    Repeater {
                        model: ["Disabled", "Hybrid", "Dedicated"]
                        PC.Button {
                            required property int index
                            required property string modelData

                            Layout.fillWidth: true
                            text: modelData
                            onClicked: updateGpu(index + 1)
                            enabled: index + 1 != gpu
                        }
                    }
                }

                // PC.Label { text: logs }
            }
        }
    }

    Plasma5Support.DataSource {
        id: executable
        engine: "executable"
        connectedSources: []
        onNewData: function(source, data) {
            disconnectSource(source)
        }

        function exec(cmd) {
            executable.connectSource(cmd)
        }
    }
}
