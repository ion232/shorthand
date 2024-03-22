use leptos::*;
use wasm_bindgen::prelude::*;

#[wasm_bindgen]
extern "C" {
    #[wasm_bindgen(js_namespace = ["window", "__TAURI__", "core"])]
    async fn invoke(cmd: &str, args: JsValue) -> JsValue;
}

#[component]
pub fn App() -> impl IntoView {
    view! {
        <main class="container">
            <table>
                <tr>
                    <td><input type="text" value="a" maxlength=1/></td>
                    <td><input type="text" value="b" maxlength=1/></td>
                    <td><input type="text" value="c" maxlength=1/></td>
                    <td><input type="text" value="d" maxlength=1/></td>
                    <td><input type="text" value="e" maxlength=1/></td>
                </tr>
                <tr>
                    <td><input type="text" value="f" maxlength=1/></td>
                    <td><input type="text" value="g" maxlength=1/></td>
                    <td><input type="text" value="h" maxlength=1/></td>
                    <td><input type="text" value="i" maxlength=1/></td>
                    <td><input type="text" value="j" maxlength=1/></td>
                </tr>
                <tr>
                    <td><input type="text" value="k" maxlength=1/></td>
                    <td><input type="text" value="l" maxlength=1/></td>
                    <td><input type="text" value="m" maxlength=1/></td>
                    <td><input type="text" value="n" maxlength=1/></td>
                    <td><input type="text" value="o" maxlength=1/></td>
                </tr>
                <tr>
                    <td><input type="text" value="p" maxlength=1/></td>
                    <td><input type="text" value="r" maxlength=1/></td>
                    <td><input type="text" value="s" maxlength=1/></td>
                    <td><input type="text" value="t" maxlength=1/></td>
                    <td><input type="text" value="u" maxlength=1/></td>
                </tr>
                <tr>
                    <td><input type="text" value="v" maxlength=1/></td>
                    <td><input type="text" value="w" maxlength=1/></td>
                    <td><input type="text" value="x" maxlength=1/></td>
                    <td><input type="text" value="y" maxlength=1/></td>
                    <td><input type="text" value="z" maxlength=1/></td>
                </tr>
            </table>
        </main>
    }
}
