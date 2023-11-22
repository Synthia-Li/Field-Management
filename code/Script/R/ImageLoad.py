import PIL
from PIL import Image

file_in = "C:\\Users\\KevinXie\\Desktop\\test\\2020-2021诸暨油菜预实验-RGB.tif"

PIL.Image.MAX_IMAGE_PIXELS = None



im = Image.open(file_in)
print(im.format, im.size, im.mode)
im.show()



del img
