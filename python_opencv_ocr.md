# python+opencv+OCR

reference: <http://www.tramvm.com/2017/05/recognize-text-from-image-with-python.html>

## Requires

* Python 2.7
* Pillow (3.4.2)
* pytesseract (0.1.6) => OCR
* numpy (1.11.2)
* Opencv-2.4.13 (cv2) => OpenCV

## python

* Pillow
    ```bash
    pip install Pillow
    ```
* numpy
    ```bash
    pip install numpy
    ```

## opencv

## OCR

* pytesseract
    ```bash
    apt install tesseract-ocr
    pip install pytesseract
    ```

## code

```python
import cv2
import numpy as np
import pytesseract
from PIL import Image

# Path of working folder on Disk
src_path = "E:/Lab/Python/Project/OCR/"

def get_string(img_path):
    # Read image with opencv
    img = cv2.imread(img_path)

    # Convert to gray
    img = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)

    # Apply dilation and erosion to remove some noise
    kernel = np.ones((1, 1), np.uint8)
    img = cv2.dilate(img, kernel, iterations=1)
    img = cv2.erode(img, kernel, iterations=1)

    # Write image after removed noise
    cv2.imwrite(src_path + "removed_noise.png", img)

    #  Apply threshold to get image with only black and white
    #img = cv2.adaptiveThreshold(img, 255, cv2.ADAPTIVE_THRESH_GAUSSIAN_C, cv2.THRESH_BINARY, 31, 2)

    # Write the image after apply opencv to do some ...
    cv2.imwrite(src_path + "thres.png", img)

    # Recognize text with tesseract for python
    result = pytesseract.image_to_string(Image.open(src_path + "thres.png"))

    # Remove template file
    #os.remove(temp)

    return result


print '--- Start recognize text from image ---'
print get_string(src_path + "2.png")

print "------ Done -------"
```