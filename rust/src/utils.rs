
pub fn generate_random_data() -> String {
    let data = rand::random::<[u8; 32]>();

    let hex_string = hex::encode(data);
    println!("\nRANDOM CHALLENG DATA:: {:?}\n", &hex_string);
    hex_string
}
