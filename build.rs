fn main() {
    // Generate UniFFI scaffolding from UDL file
    uniffi::generate_scaffolding("src/template.udl").unwrap();
}
