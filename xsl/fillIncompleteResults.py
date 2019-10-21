import sys, os, json, subprocess, time, datetime
from datetime import timedelta
from multiprocessing import Pool

def fillIncompleteResults(output_folder):
	incomplete_folder = output_folder + 'incomplete/'
	complete_folder = output_folder + 'complete/'

	with open(output_folder + 'dicts/meta.json','r') as meta_readfile:
		meta = json.load(meta_readfile)

	with open(output_folder + 'reports/missing_metadata.txt','w') as err_file:
		for root, dirs, files in os.walk(incomplete_folder):
			for f in files:
				print(incomplete_folder + f)
				with open(incomplete_folder + f,'r') as readfile:
					ef = json.load(readfile)
					if 'identifier' in ef['metadata']:
						if type(ef['metadata']['identifier']) == dict and ef['metadata']['identifier']['propertyID'] == 'oclc':
							instance_id = ef['metadata']['identifier']['value']
						else:
							for ids in ef['metadata']['identifier']:
								if ids['propertyID'] == 'oclc':
									instance_id = ids['value']

							try:
								instance_id
							except NameError:
								instance_id = '_:b' + ef['metadata']['mainEntityOfPage'][0][ef['metadata']['mainEntityOfPage'][0].rfind('/')+1:]
								print(instance_id)
					elif 'mainEntityOfPage' in ef['metadata']:
						instance_id = '_:b' + ef['metadata']['mainEntityOfPage'][0][ef['metadata']['mainEntityOfPage'][0].rfind('/')+1:]
						print(instance_id)
					else:
						err_file.write(f + ' has no retrievable instance id\n')

					try:
						work_dict = meta[str(instance_id)]
						for key in work_dict.keys():
							if key not in ef['metadata'] or key == 'title':
								ef['metadata'][key] = work_dict[key]

						if 'isPartOf' in work_dict and 'isPartOf' in ef['metadata'] and len(ef['metadata']['isPartOf']['journalTitle']) == 0:
							ef['metadata']['isPartOf']['journalTitle'] = work_dict['isPartOf']['journalTitle']

						with open(complete_folder + f[:f.find('.')] + '/' + f,'w') as writefile:
							json.dump(ef,writefile,indent=4)
					except:
						err_file.write(instance_id + ' ' + f + '\n')

				if os.path.exists(complete_folder + f[:f.find('.')] + '/' + f):
					os.remove(incomplete_folder + f)

if __name__ == "__main__":
	fillIncompleteResults(sys.argv[1])