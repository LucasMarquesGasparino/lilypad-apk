# Lilypad — APK

Casca Android offline para `projects/lilypad-brincadeira`. O APK empacota a
interface, os sprites e os quatro áudios; não depende de servidor local para
abrir.

- Pacote: `com.lilypad.brincadeira` (nome: **Lilypad — brinca comigo**)
- WebView local: `file:///android_asset/lilypad-brincadeira/index.html`
- Sem permissões de rede.

## Interações (iguais às da web)

Toque livre: apresentação · olho esquerdo/direito: frases carinhosas ·
boca: despedida. Olhos seguem o dedo, piscam e a boca anima na fala.

## Compilar

```sh
cd ~/projects/lilypad-apk
bash build.sh
```

Os arquivos são copiados para `Documentos/Lilypad-Brincadeira.apk` e
`Download/Lilypad-Brincadeira.apk`.

## Estrutura

```
lilypad-apk/
├── src/com/lilypad/brincadeira/MainActivity.java
├── assets/lilypad-brincadeira/  # html + sprites + áudios
└── res/
```
