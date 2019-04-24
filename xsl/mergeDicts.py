import sys, os, json

def main():
	dict_folder = 'outputs/dicts/'

	master_instance = {}
	master_meta = {}
	for root, dirs, files in os.walk(dict_folder):
		for f in files:
			with open(dict_folder + f,'r') as readfile:
				if f[-14:-5] == '_instance':
					master_instance.update(json.load(readfile))
				else:
					print(f)
					master_meta.update(json.load(readfile))

	print(master_instance)
	print(master_meta)

main()