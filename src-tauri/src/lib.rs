use tauri::menu::{Menu, MenuItem};
use tauri::tray::TrayIconBuilder;
use tauri::{AppHandle, Manager, WindowEvent};
use tauri_plugin_shell::process::CommandChild;
use tauri_plugin_shell::ShellExt;

struct Sidecar(std::sync::Mutex<Option<CommandChild>>);

/// Sobe o daemon como sidecar quando nao ha um respondendo na porta local.
fn spawn_daemon(app: &AppHandle) {
    if daemon_alive() {
        return;
    }
    let sidecar = app.shell().sidecar("agent-hub-daemon");
    let Ok(command) = sidecar else { return };
    if let Ok((_, child)) = command.args(["start"]).spawn() {
        if let Some(state) = app.try_state::<Sidecar>() {
            *state.0.lock().unwrap() = Some(child);
        }
    }
}

fn daemon_alive() -> bool {
    std::net::TcpStream::connect_timeout(&"127.0.0.1:47311".parse().unwrap(), std::time::Duration::from_millis(300)).is_ok()
}

fn stop_daemon(app: &AppHandle) {
    if let Some(state) = app.try_state::<Sidecar>() {
        if let Some(child) = state.0.lock().unwrap().take() {
            let _ = child.kill();
        }
    }
}

pub fn run() {
    tauri::Builder::default()
        .plugin(tauri_plugin_shell::init())
        .plugin(tauri_plugin_opener::init())
        .manage(Sidecar(std::sync::Mutex::new(None)))
        .setup(|app| {
            spawn_daemon(app.handle());
            let show = MenuItem::with_id(app, "show", "Abrir", true, None::<&str>)?;
            let quit = MenuItem::with_id(app, "quit", "Sair", true, None::<&str>)?;
            let menu = Menu::with_items(app, &[&show, &quit])?;
            TrayIconBuilder::new()
                .menu(&menu)
                .icon(app.default_window_icon().unwrap().clone())
                .on_menu_event(|app, event| match event.id.as_ref() {
                    "show" => {
                        if let Some(w) = app.get_webview_window("main") {
                            let _ = w.show();
                            let _ = w.set_focus();
                        }
                    }
                    "quit" => {
                        stop_daemon(app);
                        app.exit(0);
                    }
                    _ => {}
                })
                .build(app)?;
            Ok(())
        })
        .on_window_event(|window, event| {
            if let WindowEvent::CloseRequested { api, .. } = event {
                let _ = window.hide();
                api.prevent_close();
            }
        })
        .run(tauri::generate_context!())
        .expect("falha ao iniciar o Agent Hub");
}
