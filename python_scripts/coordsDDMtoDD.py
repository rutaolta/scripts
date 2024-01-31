import csv
import re

def ddm2dd(coord):
    dd = float(coord[0]) + float(coord[1])/60
    if coord[2] in ['E', 'S']:
        dd *= -1
    return dd

def parse_ddm(ddm_coords):
    lat = ddm2dd(re.split('[°′]',coords[0]))
    long = ddm2dd(re.split('[°′]',coords[1]))
    return [str(lat), str(long)]

with open('/home/yakupova/Downloads/coords.csv') as rfile:
    with open('/home/yakupova/Downloads/coords_new.csv', 'w') as wfile:
        reader = csv.reader(rfile, delimiter=",")
        writer = csv.writer(wfile, delimiter="\t")

        for r in reader:
            coords = list(map(str.strip, r))
            # print(parse_ddm(coords))
            writer.writerow(parse_ddm(coords))
