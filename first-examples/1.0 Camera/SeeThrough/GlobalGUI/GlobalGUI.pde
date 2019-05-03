// PapARt library
import fr.inria.papart.procam.*;
import fr.inria.papart.procam.display.*;
import fr.inria.papart.procam.camera.*;
import tech.lity.rea.svgextended.*;
import org.bytedeco.javacpp.opencv_core;
import org.reflections.*;
import toxi.geom.*;
import org.openni.*;

// GUI
import tech.lity.rea.skatolo.*;
import tech.lity.rea.skatolo.events.*;
import tech.lity.rea.skatolo.gui.controllers.*;

Papart papart;
ARDisplay display;
Camera camera;

Skatolo skatolo;

PaperContent paperContent;

int paperBackgroundColor = 0;

void settings() {
  size(640, 480, P3D);
}

void setup() {
  // application only using a camera
  // screen rendering
  papart = Papart.seeThrough(this);

  // Get the AR rendering display.
  display = papart.getARDisplay();
  // Do not draw automatically.
  display.manualMode();

  camera = display.getCamera();

  paperContent = new PaperContent();

  papart.startTracking();

  // Create the Graphical interface
  skatolo = new Skatolo(this);
  skatolo.addButton("onTBoxClick")
            .setPosition(20, 20)
            .setSize(150, 20)
            .setCaptionLabel("Change paper background");
}

void onTBoxClick() {
  paperBackgroundColor += 1;
  if (paperBackgroundColor == 10) {
    paperBackgroundColor = 0;
  }
}

void draw() {
  // Ask the Display to be rendered offscreen.
  // Nothing is drawn directly here.
  display.drawScreens();

  noStroke();
  // draw the camera image
  if (camera != null && camera.getPImage() != null) {
    image(camera.getPImage(), 0, 0, width, height);
  }

  // draw the AR
  display.drawImage((PGraphicsOpenGL) g, display.render(), 0, 0, width, height);

  // Draw the GUI
  hint(ENABLE_DEPTH_TEST);
  skatolo.draw();
  hint(DISABLE_DEPTH_TEST);
}
