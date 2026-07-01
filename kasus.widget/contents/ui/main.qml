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

    property string logs: "LOGS:\n"
    property bool gpu_changed: false

    Component.onCompleted: {
        runner.exec("asus status-id fan");
        runner.exec("asus status-id cpu");
        runner.exec("asus status-id gpu");
    }

    function updateCpu(val){
        logs+="CPU S (old "+ root.cpu + " curr " + val + " loaded "+ cpuLoaded + ")\n";
        if(isNaN(val) || val < 1 || val > 3) return;

        if(!cpuLoaded){
            cpuLoaded = true;
            root.cpu = val;
            logs+="CPU L (old "+ root.cpu + " curr " + val + " loaded "+ cpuLoaded + ")\n";
            return;
        } else if(root.cpu == val){
            return;
        }

        root.cpu = val;
        logs+="CPU E (old "+ root.cpu + " curr " + val + " loaded "+ cpuLoaded + ")\n";
        runner.exec("asus cpu " + val + " --use-run0");
    }

    function updateFan(val){
        logs+="FAN S (old "+ root.fan + " curr " + val + " loaded "+ fanLoaded + ")\n";
        if(isNaN(val) || val < 1 || val > 3) return;

        if(!fanLoaded){
            fanLoaded = true;
            root.fan = val;
            logs+="FAN L (old "+ root.fan + " curr " + val + " loaded "+ fanLoaded + ")\n";
            return;
        } else if(root.fan == val){
            return;
        }


        root.fan = val;
        logs+="FAN E (old "+ root.fan + " curr " + val + " loaded "+ fanLoaded + ")\n";
        runner.exec("asus fan " + val);
    }

    function updateGpu(val){
        logs+="GPU S (old "+ root.gpu + " curr " + val + " loaded "+ gpuLoaded + ")\n";
        if(isNaN(val) || val < 1 || val > 2) return;

        if(!gpuLoaded){
            gpuLoaded = true;
            root.gpu = val;
            logs+="GPU L (old "+ root.gpu + " curr " + val + " loaded "+ gpuLoaded + ")\n";
            return;
        } else if(root.gpu == val || !gpuLoaded){
            return;
        }

        root.gpu = val;
        gpu_changed = true;
        logs+="GPU E (old "+ root.gpu + " curr " + val + " loaded "+ gpuLoaded + ")\n";
        runner.exec("asus gpu " + root.gpu);
    }

    property string statusIcon: {
        if(!loaded)
            return "paint-unknown";
        else if(cpu <= 2 && fan == 1 && gpu == 1)
            return "battery-profile-powersave";
        else if(cpu <= 2 && fan == 1 && gpu == 2)
            return "show-gpu-effects";
        else
            return "battery-profile-performance";
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

    fullRepresentation: Item { // TODO use scroll view
        Layout.minimumWidth: 300
        Layout.minimumHeight: 350


        ColumnLayout {
            anchors.fill: parent
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
                        text: "Cpu (require sudo)"
                    }
                    RowLayout {
                        id: listCpu
                        Layout.fillWidth: true

                        Repeater {
                            model: ["Powersave", "Auto", "Performance"]
                            Button {
                                required property int index
                                required property string modelData

                                Layout.fillWidth: true
                                text: modelData
                                onClicked: updateCpu(index + 1)
                                enabled: root.cpuLoaded && index + 1 != cpu
                            }
                        }
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
                        enabled: root.fanLoaded
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
                        text: "Gpu" + (gpu_changed ? " (reboot/logout now to see result)"
                                : " ")
                    }
                    RowLayout {
                        id: listGpu
                        Layout.fillWidth: true

                        Repeater {
                            model: ["Disabled", "Hybrid"]
                            Button {
                                required property int index
                                required property string modelData

                                Layout.fillWidth: true
                                text: modelData
                                onClicked: updateGpu(index + 1)
                                enabled: root.gpuLoaded && index + 1 != gpu
                            }
                        }
                    }
                    Label {
                        text: "Change gpu used enabled by cardwire [TODO dedicated gpu]"

                        color: Kirigami.Theme.disabledTextColor
                        font: Kirigami.Theme.smallFont
                        wrapMode: Text.Wrap
                        Layout.fillWidth: true
                    }
                }
            }

            ScrollView{
                Layout.fillWidth: true
                Layout.fillHeight: true

                Label{
                    Layout.fillWidth: true
                    text: logs
                    color: Kirigami.Theme.disabledTextColor
                    font: Kirigami.Theme.smallFont
                    wrapMode: Text.Wrap
                }
            }
        }

    }

    Plasma5Support.DataSource {
        id: runner
        engine: "executable"
        connectedSources: []
        onNewData: function(source, data) {
            if (data["exit code"] != 0) return;
            let output = data["stdout"];
            logs += "DATA:" + source + " -> " + output + "\n";

            if(source == "asus status-id cpu"){
                updateCpu(parseInt(output));
            }else if(source == "asus status-id fan"){
                updateFan(parseInt(output));
            }else if(source == "asus status-id gpu"){
                updateGpu(parseInt(output));
            }

            disconnectSource(source);
        }

        function exec(cmd) {
            logs += "CMD:" + cmd + "\n";
            runner.connectSource(cmd);
        }
    }
}
