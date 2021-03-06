echo download COCO dataset
LINKS="
http://images.cocodataset.org/zips/train2014.zip
http://images.cocodataset.org/zips/val2014.zip
http://images.cocodataset.org/annotations/annotations_trainval2014.zip
http://images.cocodataset.org/zips/train2017.zip
http://images.cocodataset.org/zips/val2017.zip
http://images.cocodataset.org/annotations/annotations_trainval2017.zip
"
ROOT=~/data/coco
for LINK in $LINKS
do
	aria2c --auto-file-renaming=false -d $ROOT $LINK
	unzip -n $ROOT/$(basename $LINK) -d $ROOT
done
rm $ROOT/val2014/COCO_val2014_000000320612.jpg

echo cache data
python3 cache.py -c config.ini config/original_person18_19.ini -m cache/name=cache_original

echo download and cache the original model
ROOT=~/model/openpose/pose/coco
aria2c --auto-file-renaming=false -d $ROOT https://raw.githubusercontent.com/CMU-Perceptual-Computing-Lab/openpose/master/models/pose/coco/pose_deploy_linevec.prototxt
aria2c --auto-file-renaming=false -d $ROOT http://posefs1.perception.cs.cmu.edu/OpenPose/models/pose/coco/pose_iter_440000.caffemodel
python3 convert_caffe_torch.py config/convert_caffe_torch/original_person18_19.tsv $ROOT/pose_deploy_linevec.prototxt $ROOT/pose_iter_440000.caffemodel -c config.ini config/original_person18_19.ini -m model/name=model_original -d

echo demo keypoint estimation via a webcam
python3 estimate.py -c config.ini config/original_person18_19.ini -m model/name=model_original

echo training
python3 train.py -c config.ini config/original_person18_19.ini -m cache/name=cache_original model/name=model_original