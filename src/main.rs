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

fn option_gpu(suboption: &str){
	match suboption {
		"integrated" | "i" => set_gpu_mode("Integrated"),
		"hybrid" | "h" => set_gpu_mode("Hybrid"),
		"nvidia" | "n" => set_gpu_mode("AsusMuxDgpu"),
		other => {
			println!("Gpu subption '{other}' unrecognised, try 'asus help'"); 
		}
	}
}

fn option_fan(suboption: &str){
	match suboption {
		"quiet" | "q" => set_fan_mode("Quiet"),
		"balanced" | "b" => set_fan_mode("Balanced"),
		"performance" | "p" => set_fan_mode("Performance"),
		other => {
			println!("Fan suboption '{other}' unrecognised, try 'asus help'"); 
		}
	}
}

fn option_menu(option: &str){
	let suboption = std::env::args().nth(2);

	match option {
		"gpu" => option_gpu(&suboption.unwrap_or("list".to_string())),
		"fan" => option_fan(&suboption.unwrap_or("list".to_string())),
		"help" | "-h" | "--help" => {
			println!("To change it use the following options"); 
			println!("- asus fan <option>");
			println!("\t- quiet[Q]");
			println!("\t- balanced[B]");
			println!("\t- performance[P]");
			println!("- asus gpu <option>");
			println!("\t- integrated[Q]");
			println!("\t- hybrid[B]");
			println!("\t- nvidia[P]");
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
			println!("Gpu: {}, Fan: {}", 
					get_gpu_mode(), get_fan_mode());
		}
	}
}
