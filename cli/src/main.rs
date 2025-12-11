#![warn(clippy::pedantic)]
#![warn(clippy::nursery)]
#![warn(clippy::cargo)]
#![allow(clippy::cargo_common_metadata)]

use std::process::Command;

fn get_gpu_mode() -> Option<String> {
    let output = Command::new("supergfxctl").arg("-g").output().ok()?;

    Some(
        String::from_utf8_lossy(&output.stdout)
            .replace('\n', "")
            .to_ascii_lowercase(),
    )
}

fn get_fan_mode() -> Option<String> {
    let output = Command::new("asusctl")
        .args(["profile", "-p"])
        .output()
        .ok()?;

    Some(
        String::from_utf8_lossy(&output.stdout)
            .split(' ')
            .last()?
            .replace('\n', "")
            .to_ascii_lowercase(),
    )
}

fn get_auto_cpufreq_mode() -> Option<String> {
    let output = Command::new("auto-cpufreq")
        .arg("--get-state")
        .output()
        .ok()?;

    Some(String::from_utf8_lossy(&output.stdout).trim().to_string())
}

fn set_gpu_mode(mode: &str) {
    let res = Command::new("supergfxctl").arg("-m").arg(mode).output();

    if res.is_err() {
        println!("Failed to set gpu mode");
    }
    println!("Set gpu mode to '{mode}'");
}

fn set_fan_mode(mode: &str) {
    let res = Command::new("asusctl")
        .args(["profile", "-P", mode])
        .output();

    if res.is_err() {
        println!("Failed to set fan mode");
    }
    println!("Set fan mode to '{mode}'");
}

fn set_auto_cpufreq_mode(mode: &str) {
    // TODO add setup (to add visudo)
    let res = Command::new("sudo")
        .args(["auto-cpufreq", "--force", mode])
        .output();

    if res.is_err() {
        println!("Failed to set auto-cpufreq mode");
    }
    println!("Set auto-cpufreq mode to '{mode}'");
}

fn option_gpu(suboption: &str) {
    match suboption {
        "integrated" | "i" | "1" => set_gpu_mode("Integrated"),
        "hybrid" | "h" | "2" => set_gpu_mode("Hybrid"),
        "nvidia" | "n" | "3" => set_gpu_mode("AsusMuxDgpu"),
        other => {
            println!("Gpu subption '{other}' unrecognised, try 'asus help'");
        }
    }
}

fn option_fan(suboption: &str) {
    match suboption {
        "lowpower" | "l" | "1" => set_fan_mode("Quiet"),
        "balanced" | "b" | "2" => set_fan_mode("Balanced"),
        "performance" | "p" | "3" => set_fan_mode("Performance"),
        other => {
            println!("Fan suboption '{other}' unrecognised, try 'asus help'");
        }
    }
}

fn option_auto_cpufreq(suboption: &str) {
    match suboption {
        "powersave" | "s" | "1" => set_auto_cpufreq_mode("powersave"),
        "default" | "d" | "2" => set_auto_cpufreq_mode("reset"),
        "performance" | "p" | "3" => set_auto_cpufreq_mode("performance"),
        other => {
            println!("Fan suboption '{other}' unrecognised, try 'asus help'");
        }
    }
}

fn option_status(suboption: &str) {
    let res = match suboption {
        "cpu" => get_auto_cpufreq_mode(),
        "fan" => get_fan_mode(),
        "gpu" => get_gpu_mode(),
        other => {
            println!("Status suboption '{other}' unrecognised, try 'asus help'");
            return;
        }
    };

    if let Some(res) = res {
        println!("{res}");
    }
}

fn option_status_id(suboption: &str) {
    let res = match suboption {
        "cpu" => {
            let mode = get_auto_cpufreq_mode();
            ["powersave", "reset", "performance"]
                .iter()
                .position(|&x| Some(x.to_string()) == mode)
        }
        "fan" => {
            let mode = get_fan_mode();
            ["quiet", "balanced", "performance"]
                .iter()
                .position(|&x| Some(x.to_string()) == mode)
        }
        "gpu" => {
            let mode = get_gpu_mode();
            ["integrated", "hybrid", "asusmuxdgpu"]
                .iter()
                .position(|&x| Some(x.to_string()) == mode)
        }
        other => {
            println!("Status suboption '{other}' unrecognised, try 'asus help'");
            return;
        }
    };

    if let Some(res) = res {
        println!("{}", res + 1);
        return;
    }
    println!("Cannot read value");
}

fn print_help() {
    println!("To change it use the following options");
    println!("- asus fan <option>");
    println!("\t- lowpower[/L/1]");
    println!("\t- balanced[/B/2]");
    println!("\t- performance[/P/3]");
    println!("- asus gpu <option>");
    println!("\t- integrated[/Q/1]");
    println!("\t- hybrid[/B/2]");
    println!("\t- nvidia[/P/3]");
    println!("- asus cpu <option>");
    println!("\t- powersave[/S/1]");
    println!("\t- default[/D/2]");
    println!("\t- performance[/P/3]");
    println!("- asus status <option>");
    println!("\t- cpu");
    println!("\t- fan");
    println!("\t- gpu");
    println!("- asus status-id <option>");
    println!("\t- cpu");
    println!("\t- fan");
    println!("\t- gpu");
    println!("Write 'asus help' to see this page");
}

fn option_menu(option: &str) {
    let suboption = std::env::args().nth(2);
    let suboption_str = &suboption.unwrap_or_else(|| "list".to_string());

    match option {
        "gpu" => option_gpu(suboption_str),
        "fan" => option_fan(suboption_str),
        "cpu" => option_auto_cpufreq(suboption_str),
        "status" => option_status(suboption_str),
        "status-id" => option_status_id(suboption_str),
        "help" | "-h" | "--help" => print_help(),
        other => {
            println!("Option '{other}' unrecognised, try 'asus help'");
        }
    }
}

fn main() {
    let option = std::env::args().nth(1);

    match option {
        Some(option_str) => {
            option_menu(&option_str.to_ascii_lowercase());
        }
        None => {
            println!(
                "Cpu: {}, Fan: {}, Gpu: {}",
                get_auto_cpufreq_mode().unwrap_or_else(|| "--".to_string()),
                get_fan_mode().unwrap_or_else(|| "--".to_string()),
                get_gpu_mode().unwrap_or_else(|| "--".to_string()),
            );
        }
    }
}
