use reqwest::Client;
use serde_json::Value;
use std::time::Duration;
use tauri::command;

const RESOLVE_ENDPOINT: &str =
    "http://127.0.0.1:56003/";

#[derive(Debug, serde::Deserialize)]
pub struct ResolveBridgeArgs {
    pub payload: Value,

    #[serde(default, rename = "timeoutSecs")]
    pub timeout_secs: Option<u64>,
}

#[command]
pub async fn resolve_bridge(
    args: ResolveBridgeArgs,
) -> Result<String, String> {

    let timeout_secs =
        args.timeout_secs.unwrap_or(15);

    let client =
        Client::builder()
            .connect_timeout(
                Duration::from_secs(3)
            )
            .timeout(
                Duration::from_secs(timeout_secs)
            )
            .build()
            .map_err(|e| {
                format!(
                    "Falha ao criar cliente HTTP: {}",
                    e
                )
            })?;

    println!(
        "[EditCOPY Bridge] POST {} func={:?}",
        RESOLVE_ENDPOINT,
        args.payload.get("func")
    );

    let response =
        client
            .post(RESOLVE_ENDPOINT)
            .header(
                "Content-Type",
                "application/json"
            )
            .json(&args.payload)
            .send()
            .await
            .map_err(|e| {

                if e.is_connect() {
                    "DaVinci Resolve não está conectado. Execute Workspace → Scripts → EditCOPY.".to_string()

                } else if e.is_timeout() {
                    format!(
                        "DaVinci Resolve não respondeu dentro de {} segundos.",
                        timeout_secs
                    )

                } else {
                    format!(
                        "Erro HTTP ao comunicar com DaVinci Resolve: {}",
                        e
                    )
                }
            })?;

    let status =
        response.status();

    let body =
        response
            .text()
            .await
            .map_err(|e| {
                format!(
                    "Falha ao ler resposta do Lua Server: {}",
                    e
                )
            })?;

    println!(
        "[EditCOPY Bridge] HTTP {}",
        status.as_u16()
    );

    println!(
        "[EditCOPY Bridge] BODY: {}",
        body
    );

    if !status.is_success() {
        return Err(format!(
            "Lua Server retornou HTTP {}: {}",
            status.as_u16(),
            body
        ));
    }

    Ok(body)
}
