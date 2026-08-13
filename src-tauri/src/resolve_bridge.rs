use serde::{Deserialize, Serialize};
use tauri::{command, AppHandle, Runtime};
use reqwest::Client;
use std::time::Duration;

#[derive(Debug, Serialize, Deserialize)]
pub struct BridgePayload {
    pub func: String,
    #[serde(flatten)]
    pub data: serde_json::Value,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct BridgeResponse {
    pub ok: boolean,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub error: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub detail: Option<String>,
    pub func: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub data: Option<serde_json::Value>,
}

#[command]
pub async fn resolve_bridge<R: Runtime>(
    _app: AppHandle<R>,
    payload: BridgePayload,
    timeout_secs: Option<u64>,
) -> Result<serde_json::Value, String> {
    let client = Client::builder()
        .timeout(Duration::from_secs(timeout_secs.unwrap_or(15)))
        .build()
        .map_err(|e| format!("Erro ao criar cliente HTTP: {}", e))?;

    let url = "http://127.0.0.1:56002/";

    println!("[Resolve Bridge] Chamando {} no Resolve...", payload.func);

    let response = client
        .post(url)
        .json(&payload)
        .send()
        .await
        .map_err(|e| {
            if e.is_connect() {
                "DaVinci Resolve não está conectado ou o script EditCOPY não foi iniciado.".to_string()
            } else if e.is_timeout() {
                "Tempo limite de conexão esgotado.".to_string()
            } else {
                format!("Erro de conexão: {}", e)
            }
        })?;

    let status = response.status();
    if !status.is_success() {
        return Err(format!("Servidor Resolve retornou erro HTTP {}", status));
    }

    let res_body: serde_json::Value = response
        .json()
        .await
        .map_err(|e| format!("Resposta do Resolve não é um JSON válido: {}", e))?;

    Ok(res_body)
}
