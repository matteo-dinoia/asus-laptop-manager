use std::process::Command;

fn get_gpu_mode() -> String{
	let output = Command::new("supergfxctl")
			.arg("-g")
			.output().unwrap();

	return String::from_utf8_lossy(&output.stdout)
			.replace("\n", "")
			.to_string();
}

fn get_fan_mode() -> String{
	let output = Command::new("asusctl")
			.arg("profile").arg("-p")
			.output().unwrap();


	return String::from_utf8_lossy(&output.stdout)
			.split(" ").last().unwrap()
			.replace("\n", "")
			.to_string();
}

fn get_auto_cpufreq_mode() -> String{
	return "'Not implemented yet'".to_string();
}

fn set_gpu_mode(mode: &str){
	Command::new("supergfxctl")
			.arg("-m")
			.arg(mode)
			.output().unwrap();
	
	println!("Set gpu mode to '{mode}'");
}

fn set_fan_mode(mode: &str){
	Command::new("asusctl")
			.arg("profile")
			.arg("-P")
			.arg(mode)
			.output().unwrap();

	println!("Set fan mode to '{mode}'");
}

fn set_auto_cpufreq_mode(mode: &str){
	Command::new("sudo")
			.arg("auto-cpufreq")
			.arg("--force")
			.arg(mode)
			.output().unwrap();

	println!("Set auto-cpufreq mode to '{mode}'");
}

fn option_gpu(suboption: &str){
	match suboption {
		"integrated" | "i" | "1" => set_gpu_mode("Integrated"),
		"hybrid" | "h" | "2" => set_gpu_mode("Hybrid"),
		"nvidia" | "n" | "3" => set_gpu_mode("AsusMuxDgpu"),
		other => {
			println!("Gpu subption '{other}' unrecognised, try 'asus help'"); 
		}
	}
}

fn option_fan(suboption: &str){
	match suboption {
		"quiet" | "q" | "1" => set_fan_mode("Quiet"),
		"balanced" | "b" | "2" => set_fan_mode("Balanced"),
		"performance" | "p" | "3" => set_fan_mode("Performance"),
		other => {
			println!("Fan suboption '{other}' unrecognised, try 'asus help'"); 
		}
	}
}

fn option_auto_cpufreq(suboption: &str){
	match suboption {
		"powersave" | "s" | "1" => set_auto_cpufreq_mode("powersave"),
		"default" | "d" | "2" => set_auto_cpufreq_mode("reset"),
		"performance" | "p" | "3" => set_auto_cpufreq_mode("performance"),
		other => {
			println!("Fan suboption '{other}' unrecognised, try 'asus help'");
		}
	}
}

fn option_menu(option: &str){
	let suboption = std::env::args().nth(2);
	let suboption_str = &suboption.unwrap_or("list".to_string());

	match option {
		"gpu" => option_gpu(suboption_str),
		"fan" => option_fan(suboption_str),
		"cpu" | "freq" | "cpufreq" | "auto_cpufreq" => option_auto_cpufreq(suboption_str),
		"help" | "-h" | "--help" => {
			println!("To change it use the following options"); 
			println!("- asus fan <option>");
			println!("\t- quiet[/Q/1]");
			println!("\t- balanced[/B/2]");
			println!("\t- performance[/P/3]");
			println!("- asus gpu <option>");
			println!("\t- integrated[/Q/1]");
			println!("\t- hybrid[/B/2]");
			println!("\t- nvidia[/P/3]");
			println!("Write 'asus help' to see this page");
			// TODO update
		}
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
			println!("Cpu: {}, Fan: {}, Gpu: {}", 
					get_auto_cpufreq_mode(), get_fan_mode(), get_gpu_mode(),);
		}
	}
}
