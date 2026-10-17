package br.com.arraial.guardioes;

import android.graphics.Rect;
import android.util.DisplayMetrics;

import androidx.core.util.Consumer;
import androidx.window.java.layout.WindowInfoTrackerCallbackAdapter;
import androidx.window.layout.DisplayFeature;
import androidx.window.layout.FoldingFeature;
import androidx.window.layout.WindowInfoTracker;
import androidx.window.layout.WindowLayoutInfo;

import com.getcapacitor.JSObject;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.CapacitorPlugin;

import java.util.concurrent.Executor;

/**
 * Le a posicao da dobra em aparelhos dobraveis (Jetpack WindowManager) e avisa a camada web.
 * Evento "fold": { state: "flat" | "half" | "none", orientation: "horizontal" | "vertical",
 *                  top, bottom, left, right (em pixels CSS), screenWidth, screenHeight }
 */
@CapacitorPlugin(name = "Fold")
public class FoldPlugin extends Plugin {

    private WindowInfoTrackerCallbackAdapter tracker;
    private JSObject last = emptyInfo();

    private final Consumer<WindowLayoutInfo> listener = info -> {
        last = toJs(info);
        notifyListeners("fold", last, true);
    };

    @Override
    public void load() {
        tracker = new WindowInfoTrackerCallbackAdapter(WindowInfoTracker.getOrCreate(getActivity()));
    }

    @Override
    protected void handleOnResume() {
        Executor main = getActivity().getMainExecutor();
        tracker.addWindowLayoutInfoListener(getActivity(), main, listener);
    }

    @Override
    protected void handleOnPause() {
        tracker.removeWindowLayoutInfoListener(listener);
    }

    @PluginMethod
    public void getPosture(PluginCall call) {
        call.resolve(last);
    }

    private JSObject emptyInfo() {
        JSObject o = new JSObject();
        o.put("state", "none");
        return o;
    }

    private JSObject toJs(WindowLayoutInfo info) {
        float density = getActivity().getResources().getDisplayMetrics().density;
        DisplayMetrics dm = getActivity().getResources().getDisplayMetrics();
        for (DisplayFeature f : info.getDisplayFeatures()) {
            if (!(f instanceof FoldingFeature)) continue;
            FoldingFeature ff = (FoldingFeature) f;
            Rect b = ff.getBounds();
            JSObject o = new JSObject();
            o.put("state", ff.getState() == FoldingFeature.State.HALF_OPENED ? "half" : "flat");
            o.put("orientation", ff.getOrientation() == FoldingFeature.Orientation.HORIZONTAL ? "horizontal" : "vertical");
            o.put("separating", ff.isSeparating());
            o.put("top", b.top / density);
            o.put("bottom", b.bottom / density);
            o.put("left", b.left / density);
            o.put("right", b.right / density);
            o.put("screenWidth", dm.widthPixels / density);
            o.put("screenHeight", dm.heightPixels / density);
            return o;
        }
        return emptyInfo();
    }
}
