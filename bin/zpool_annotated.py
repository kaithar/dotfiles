import sys
import os
import libzfs
import parted

drives = []
rmap = {}

for d in os.listdir('/dev'):
	if d.startswith('sd') and not d[-1] in "0123456789":
		drives.append(d)

drives = dict([(k,([],[])) for k in drives])
rmap.update(dict([k,k] for k in drives.keys()))

for d in os.listdir('/dev/disk/by-id'):
	tgt = os.readlink('/dev/disk/by-id/{}'.format(d)).split('/')[-1]
	if tgt in drives:
		drives[tgt][0].append(d)
		rmap[d] = tgt

for pool in libzfs.ZFS().pools:
	for d in pool.disks:
		if d.startswith('/dev/disk/by-id'):
			tgt = d.split('/')[-1].split('-part')[0]
		else:
			tgt = d.split('/')[-1].strip('0123456789')
		tgt = rmap.get(tgt, None)
		if tgt in drives:
			drives[tgt][1].append(pool)
		else:
			print('Orphan! {} -> {}'.format(d, tgt))

keys = list(drives.keys())
keys.sort()

output = {}

for k in keys:
	drives[k][0].sort()
	slots = ['','','',[]]
	for s in drives[k][0]:
		if s.startswith('wwn-'):
			slots[2] = s
		elif '_' in s:
			slots[0] = s
		elif s.startswith('scsi-'):
			slots[1] = s
		else:
			slots[3].append(S)
	#
	dev = parted.getDevice('/dev/{}'.format(k))
	capacity = dev.length * dev.sectorSize
	if (capacity > 10**12):
		capacity = '{:.3} {}'.format(capacity/10**12, 'TB')
	elif (capacity > 10**9):
		capacity = '{:.3} {}'.format(capacity/10**9, 'GB')
	else:
		capacity = '{:.3} {}'.format(capacity/10**6, 'MB')
	#
	output.setdefault(capacity, []).append('{} : {: >10} : {: >12} : {: >45} : {: >22} : {: >22} : {}'.format(
                                   k, capacity, (drives[k][1][0].name if drives[k][1] else ''),
                                   slots[0],  slots[1],  slots[2],
                                   ', '.join(slots[3])))

for k in output.keys():
	for l in output[k]:
		print(l)
	print("")

