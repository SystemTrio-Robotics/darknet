### How to train (to detect your custom objects)

These steps are only needed in the case that a different than yolov3-tiny network needs to be trained. If you need to train yolov3-tiny, skip to step 2 and just updated the already existing files that are mentioned.
Here, the main points are going to be described, for a full detailed explanation, go to https://github.com/AlexeyAB/darknet/blob/master/README.md

Training Yolo v4 (and v3):

(If you have a GPU, go to darknet/Makefile and make GPU=1. Go to darknet/ and do `make`)

0. For training we need the pre-trained weight files. In the case of yolov3-tiny, it's the `yolov3-tiny.conv.11` which is already placed in the darknet folder. 

1. A new configuration file needs to be created, based on the original one, e.g., inside darknet/cfg there is `yolov3-tiny_obj.cfg`, which was a copy of the original `yolov3-tiny.cfg` with the following modifications.

* In the first lines of the file uncomment the Training Batch + Subdivisions and comment the Testing Batch + Subdivions (We are going to do Training, not Testing). batch=64, subdivisions=16.
* Set network size `width=416 height=416` or any value multiple of 32.
* Change line max_batches to (`classes*2000` but not less than number of training images, but not less than number of training images and not less than `6000`), in our case, we have 5 classes, so `max_batches=10000`.
* Change line steps to 80% and 90% of max_batches, in our case `steps=8000,9000`.
* Change line `classes=80` to your number of objects in each `[yolo]`-layers (search for `[yolo]`). In our case `classes=5`.
* Change [`filters=255`] to filters=(classes + 5)x3 in the `[convolutional]` before each `[yolo]` layer, keep in mind that it only has to be the last `[convolutional]` before each of the `[yolo]` layers. In our cases `filters=30`.
**(Do not write in the cfg-file: filters=(classes + 5)x3)**
* (Not for our current case) When using [`[Gaussian_yolo]`], refer to https://github.com/AlexeyAB/darknet/blob/master/README.md.

2. Create file `obj.names` in the directory `darknet/data/`, with objects names - each in new line. 

3. Create file `obj.data` in the directory `darknet/data`, containing (where **classes = number of objects**):

  ```ini
  classes = 5
  train = data/train.txt
  valid = data/test.txt
  names = data/obj.names
  backup = backup/
  ```

4. Put image-files (.jpg) of your objects in the directory `darknet/data/obj/`. 

5. You should label each object on images from your dataset. Use this visual GUI-software for marking bounded boxes of objects and generating annotation files for Yolo v2 & v3: https://github.com/AlexeyAB/Yolo_mark **Every single image needs a .txt, even an empty one.**

Each .txt should be named the same as the corerspondent image and contain:

`<object-class> <x_center> <y_center> <width> <height>`

  Where: 
  * `<object-class>` - integer object number from `0` to `(classes-1)`
  * `<x_center> <y_center> <width> <height>` - float values **relative** to width and height of image, it can be equal from `(0.0 to 1.0]`
  * for example: `<x> = <absolute_x> / <image_width>` or `<height> = <absolute_height> / <image_height>`
  * atention: `<x_center> <y_center>` - are center of rectangle (are not top-left corner)

6. Create file `train.txt` in directory `darknet/data`, with filenames of your images, each filename in new line, with path relative to `darknet.exe`, for example containing: 

  ```
  data/obj/img1.jpg
  data/obj/img2.jpg
  data/obj/img3.jpg
  ```
**Be careful with empty lines, they will crash your training!**

7. Start training by using the command line: `./darknet detector train {.data file} {.cfg file} {pre-trained .weights}`
Example: `./darknet detector train data/obj.data cfg/yolov3-tiny_obj.cfg yolov3-tiny.conv.11`
  
   * (file `yolo-obj_last.weights` will be saved to the `darknet/backup/` for each 100 iterations)
   * (file `yolo-obj_xxxx.weights` will be saved to the `darknet/backup/` for each 1000 iterations)
   * (to disable Loss-Window use `./darknet detector train data/obj.data cfg/yolov3-tiny_obj.cfg yolov3-tiny.conv.11-dont_show`, if you train on computer without monitor like a cloud Amazon EC2)
   * (to see the mAP & Loss-chart during training on remote server without GUI, use command `./darknet detector train data/obj.data cfg/yolov3-tiny_obj.cfg yolov3-tiny.conv.11 -dont_show -mjpeg_port 8090 -map` then open URL `http://ip-address:8090` in Chrome/Firefox browser)

7.1. For training with mAP (mean average precisions) calculation for each 4 Epochs (set `valid=valid.txt` or `train.txt` in `obj.data` file) and run: `./darknet detector train data/obj.data cfg/yolov3-tiny_obj.cfg yolov3-tiny.conv.11 -map`

9. After training is complete - get result `yolo-obj_final.weights` from path `darknet/backup/`

 * After each 100 iterations you can stop and later start training from this point. For example, after 2000 iterations you can stop training, and later just start training using: `./darknet detector train data/obj.data cfg/yolo-obj.cfg backup/yolo-obj_2000.weights`

    (in the original repository https://github.com/pjreddie/darknet the weights-file is saved only once every 10 000 iterations `if(iterations > 1000)`)

 * Also you can get result earlier than all 45000 iterations.
 
 **Note:** If during training you see `nan` values for `avg` (loss) field - then training goes wrong, but if `nan` is in some other lines - then training goes well.
 
 **Note:** If you changed width= or height= in your cfg-file, then new width and height must be divisible by 32.
 
 **Note:** After training use such command for detection: `./darknet detector test data/obj.data cfg/yolo-obj.cfg yolo-obj_8000.weights`
 
 **Note:** if error `Out of memory` occurs then in `.cfg`-file you should increase `subdivisions=16`, 32 or 64. (Step 1)