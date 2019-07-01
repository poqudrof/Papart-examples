import fr.inria.papart.depthcam.DepthData;
import java.util.ArrayList;
import toxi.geom.Vec3D;
import fr.inria.papart.depthcam.*;
import fr.inria.papart.procam.display.*;
import fr.inria.papart.calibration.*;
import fr.inria.papart.multitouch.*;
import fr.inria.papart.multitouch.detection.*;
import fr.inria.papart.multitouch.tracking.*;
import fr.inria.papart.depthcam.devices.*;

public class TouchDepthView extends PaperTouchScreen {

  PMatrix3D depthCamExtrinsics;
  PMatrix3D currentLocationInv;

  float ellipseSize = 3f;

  void settings() {
    setDrawAroundPaper();
    setDrawingSize(297, 210);
    loadMarkerBoard(Papart.markerFolder + "A4-default.svg", 297, 210);
  }

  void setup() {
    DepthCameraDevice depthCamera = papart.getDepthCameraDevice();
    depthCamExtrinsics = depthCamera.getStereoCalibration();
  }

  void drawAroundPaper() {

    // Go to the origin of the projection
    translate(0, getDrawingSize().y);
    scale(1, -1, 1);

    currentLocationInv = getLocation().get();
    currentLocationInv.invert();

    rect(0, 0, 10, 20);
    noStroke();

    // Get the touchInput
    DepthTouchInput touchInput = (DepthTouchInput) getTouchInput();

    FingerDetection fingerDetection = touchInput.getFingerDetection();
    HandDetection handDetection = touchInput.getHandDetection();
    ArmDetection armDetection = touchInput.getArmDetection();

    ArrayList<TrackedDepthPoint> armTouch = new ArrayList((ArrayList<TrackedDepthPoint>)armDetection.getTouchPoints());
    ArrayList<TrackedDepthPoint> armPointerTouch = new ArrayList((ArrayList<TrackedDepthPoint>)armDetection.getTipPoints());
    ArrayList<TrackedDepthPoint> handTouch = new ArrayList((ArrayList<TrackedDepthPoint>)handDetection.getTouchPoints());
    ArrayList<TrackedDepthPoint> fingerTouch = new ArrayList((ArrayList<TrackedDepthPoint>)fingerDetection.getTouchPoints());

    if (DRAW_ARM) {
      pushStyle();
      {
        fill(0, 0, 255);
        ellipseSize = 5f;
        drawDepthElements(armTouch);
      }
      popStyle();
    }

    if (DRAW_HAND) {
      pushStyle();
      {
        fill(0, 255, 0);
        ellipseSize = 5f;
        drawDepthElements(handTouch);
      }
      popStyle();
    }

    if (DRAW_FINGER) {
      pushStyle();
      {
        fill(255);
        ellipseSize = 2f;
        drawDepthElements(fingerTouch);
      }
      popStyle();
    }

    if (DRAW_TIP) {
      pushStyle();
      {
        fill(255, 0, 0);
        ellipseSize = 12f;
        drawDepthElements(armPointerTouch);
      }
      popStyle();
    }
  }

  void drawDepthElements(ArrayList<TrackedDepthPoint> touchList) {
    for (TrackedDepthPoint tp : touchList) {
      ArrayList<DepthDataElementProjected> depthDataElements = tp.getDepthDataElements();
      for (DepthDataElementProjected dde : depthDataElements) {
        drawPoint(dde);
      }
    }
  }

  void drawPoint(DepthDataElementProjected dde) {

    Vec3D depthPoint = dde.depthPoint;
    PVector pointPosExtr = new PVector();
    PVector pointPosDisplay = new PVector();
    depthCamExtrinsics.mult(new PVector(depthPoint.x,
                                        depthPoint.y,
                                        depthPoint.z),
                                        pointPosExtr);

    currentLocationInv.mult(pointPosExtr, pointPosDisplay);

    pushMatrix();
    {
      ellipseMode(CENTER);
      translate(pointPosDisplay.x, pointPosDisplay.y, pointPosDisplay.z );
      ellipse(-2, -2, ellipseSize, ellipseSize);
    }
    popMatrix();
  }
}