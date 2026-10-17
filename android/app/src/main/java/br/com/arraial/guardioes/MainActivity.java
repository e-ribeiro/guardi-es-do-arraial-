package br.com.arraial.guardioes;

import android.os.Bundle;
import android.view.WindowManager;

import com.getcapacitor.BridgeActivity;

public class MainActivity extends BridgeActivity {
    @Override
    public void onCreate(Bundle savedInstanceState) {
        registerPlugin(FoldPlugin.class);
        super.onCreate(savedInstanceState);
        // Jogo relaxante: a tela nao apaga no meio de uma onda.
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
    }
}
