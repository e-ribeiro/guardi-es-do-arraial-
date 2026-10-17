# Guardiões do Arraial

Tower defense relaxante com encantados do folclore e heróis do cotidiano brasileiro. App híbrido (Capacitor): o jogo é uma página HTML5 em `www/`, embalada como app nativo. Android pronto neste repositório; iOS sai do mesmo código.

## Estrutura

```
www/index.html        o jogo inteiro (HTML, CSS, JS, sem dependências externas)
capacitor.config.json id do app, nome, pasta web
android/              projeto Android gerado pelo Capacitor
  app/src/main/java/br/com/arraial/guardioes/
    MainActivity.java registra o plugin Fold e mantém a tela acesa
    FoldPlugin.java   lê a dobra via Jetpack WindowManager e avisa o jogo
```

## Compilar o APK (Android)

Requisitos: Android Studio (Ladybug ou mais novo), JDK 21, Node 20 ou mais novo.

1. `npm install`
2. `npx cap sync android` (copia `www/` para dentro do projeto Android; repita depois de qualquer mudança no jogo)
3. `npx cap open android` abre o projeto no Android Studio
4. Build > Build Bundle(s) / APK(s) > Build APK(s)

Ou pela linha de comando, dentro de `android/`: `./gradlew assembleDebug`. O APK fica em `android/app/build/outputs/apk/debug/`.

Tamanho esperado do APK: perto de 4 MB. O jogo não usa internet; a permissão INTERNET vem do template do Capacitor e pode ser removida do manifesto se quiser.

## iOS (depois)

Em um Mac com Xcode: `npm run ios`. O Capacitor gera a pasta `ios/` a partir do mesmo `www/`. O plugin Fold é só Android; no iOS o jogo roda no layout normal (retrato ou paisagem), que já é o que acontece em qualquer aparelho sem dobra.

## Modo 3DS (dobrável)

Com o aparelho meio dobrado na horizontal (Galaxy Z Fold ou Flip apoiado como um notebook, Pixel Fold e similares), o jogo passa para duas telas:

- Tela de cima: só o tabuleiro.
- Tela de baixo: milho, moedas, botão de onda, tela auxiliar (composição da próxima onda e torre selecionada com Evoluir e Vender) e os personagens com nome.

Como o jogo descobre a dobra, em ordem:

1. Plugin nativo `Fold` (Jetpack WindowManager `FoldingFeature`): estado HALF_OPENED com orientação horizontal, mais a posição exata da dobra em pixels CSS. Funciona no app.
2. Device Posture API e segmentos do viewport (Chrome). Funciona se o jogo for aberto no navegador.
3. Escolha manual no menu: Modo 3DS automático, ligado ou desligado. Serve para testar em qualquer aparelho.

Aberto todo (flat) ou fechado, o layout volta ao normal: tabuleiro grande com a faixa de personagens embaixo (retrato) ou na lateral (paisagem). A troca é instantânea porque é só CSS Grid lendo duas variáveis (`--top-h` e `--hinge-h`).

Para testar no emulador: crie um AVD de dobrável (Pixel Fold ou 7.6" Fold-in) e use o controle de postura da barra lateral do emulador (Half-folded).

## Jogo

- Torres: Saci, Cachorro Caramelo, Gato Laranja, Gari, Curupira, Zé Gotinha, Iara, Boitatá. Herói móvel: Motoboy.
- Pragas: saúva, gafanhoto, pernilongo, cupim, sacola voadora, boleto vencido (chefe nas ondas 5), tatu-bola (chefe nas ondas 10).
- Fases: Arraial, Beira-mar, Sertão (2 entradas), Centro (2 entradas que se cruzam); depois os mapas repetem com força maior.
- Sem game over: ao perder o milho, a onda repete um pouco mais fraca e as torres ficam.
- Progresso salvo no aparelho (localStorage do WebView).

## Próximos passos sugeridos

- Ícone e splash próprios (`android/app/src/main/res/`); hoje são os do template.
- Trilha sonora: o jogo tem só notas pentatônicas sintetizadas via WebAudio.
- Assinatura do APK de release para publicar na Play Store.
