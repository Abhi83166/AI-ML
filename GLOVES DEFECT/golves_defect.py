import cv2 as cv
import imutils
#For code explanation read the documentation attached

font = cv.FONT_HERSHEY_SIMPLEX#change font as desired

def orientation_detection(count):
    if len(count) == 0:
        print('Connection')
    else:
        try:
            count = imutils.grab_contours(count)
            c = max(count, key=cv.contourArea)
            extLeft = tuple(c[c[:, :, 0].argmin()][0])
            extRight = tuple(c[c[:, :, 0].argmax()][0])
            extTop = tuple(c[c[:, :, 1].argmin()][0])
            extBot = tuple(c[c[:, :, 1].argmax()][0])
            if extTop[0] > extBot[0]:
                cv.putText(frame, "LEFT GLOVE", (50, 50), font, 2, (255, 255, 0))
            elif extTop[0] < extBot[0]:
                cv.putText(frame, "RIGHT GLOVE", (50, 50), font, 2, (255, 255, 0))
        except ValueError:
            cv.putText(frame, "NO GLOVE DETECTED", (50, 50), font, 1, (255, 255, 0))


def defect_measurement(cnt):
    area = cv.contourArea(cnt)
    approx = cv.approxPolyDP(cnt, 0.009 * cv.arcLength(cnt, True), True)
    x = approx.ravel()[0]
    y = approx.ravel()[1]
    if 15 > len(approx) > 3:
        if area > 500:
            print(approx)
            cv.drawContours(frame, [approx], 0, (255, 255, 0), 3)
            cv.putText(frame, "DEFECTED", (x, y), font, 1, (0, 255, 0))
    cv.putText(frame, "AREA :-" + str(area), (x, y+25), font, 1, (0, 255, 0))

fr = cv.videocapture(0)

while True:
    ret, frame = fr.read()
    gray = cv.cvtColor(frame, cv.COLOR_BGR2GRAY)
    thres = cv.threshold(gray, 110, 150, cv.THRESH_BINARY)[1]
    thres = cv.erode(thres, None, iterations=1)
    thres = cv.dilate(thres, None, iterations=1)
    thres = cv.Canny(thres, 90, 180)
    _, contours, _ = cv.findContours(thres, cv.RETR_TREE, cv.CHAIN_APPROX_SIMPLE)
    cv.imshow('frame', frame)
    orientation_detection(contours)
    defect_measurement(contours)
    if cv.waitKey(1) & 0xFF == ord('q'):
        break

# After the loop release the cap object
fr.release()
# Destroy all the windows
cv.destroyAllWindows()


