
from PIL import Image
import cairosvg
import uuid
import os
from shutil import copyfile

# works for gif/png/jpeg
# NB: This creates a good conversion of the Pixel to Vector by created coloured squares. Output is massive, obviously.
def to_svg(original_path, converted_path):
    image = Image.open(original_path).convert('RGBA')
    data = image.load()
    out = open(converted_path, "w")
    out.write('<?xml version="1.0" encoding="UTF-8" standalone="no"?>\n')
    out.write('<svg id="svg2" xmlns="http://www.w3.org/2000/svg" version="1.1" width="%(x)i" height="%(y)i" viewBox="0 0 %(x)i %(y)i">\n' % {'x':image.size[0], 'y':image.size[1]})
    for y in range(image.size[1]):
        for x in range(image.size[0]):
            rgba = data[x, y]
            rgb = '#%02x%02x%02x' % rgba[:3]
            if rgba[3] > 0:
                out.write('<rect width="1" height="1" x="%i" y="%i" fill="%s" fill-opacity="%.2f" />\n' % (x, y, rgb, rgba[3]/255.0))
    out.write('</svg>\n')
    out.close()

    return converted_path

def to_jpeg(original_path, converted_path):
    im = Image.open(original_path)
    rgb_im = im.convert('RGB')
    rgb_im.save(converted_path)
    return converted_path

def to_gif(original_path, converted_path):
    im = Image.open(original_path)

    im = im.convert('RGB').convert('P', palette=Image.ADAPTIVE)
    im.save(converted_path)
    return converted_path

def svg_to_jpeg(original_path, converted_path):
    # convert svg to png then to jpeg
    tmp_file="tmp{uuid}.svg".format(uuid=uuid.uuid4())
    svg_to_png(original_path, tmp_file)
    to_jpeg(tmp_file, converted_path)
    os.remove(tmp_file)
    return converted_path

def svg_to_gif(original_path, converted_path):
    # convert svg to png then to jpeg
    tmp_file="tmp{uuid}.svg".format(uuid=uuid.uuid4())
    svg_to_png(original_path, tmp_file)
    to_gif(tmp_file, converted_path)
    os.remove(tmp_file)
    return converted_path

def to_png(original_path, converted_path):
    im = Image.open(original_path)
    # transparency = im.info['transparency']
    im.save(converted_path)#, transparency=transparency)
    return converted_path

def svg_to_png(original_path, converted_path):
    cairosvg.svg2png(url=original_path, write_to=converted_path)
    return converted_path

def no_conversion(original_path, converted_path):
    # same file type, ignore
    copyfile(original_path, converted_path)
    return converted_path
