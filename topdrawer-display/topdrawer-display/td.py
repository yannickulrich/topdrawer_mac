#import matplotlib
#matplotlib.use('Agg')
#import matplotlib.pyplot as plt
#import numpy as np
import sys,re,os
import subprocess

def gnuplot(plotdata, xlabel, ylabel, xlim):
	#global basepath
	#print basepath
	#with open("out.gnu", "w") as fp:
	#	fp.write(plotdata)
	proc = subprocess.Popen("gnuplot", stdin=subprocess.PIPE, stdout=subprocess.PIPE) #, cwd=basepath)
	return proc.communicate("""
set terminal svg
set xlabel '%s'
set ylabel '%s'
set xrange [%f:%f]
set key off
plot "-" using 1:2:($2-$3):($2+$3) with errorbars
""" % (xlabel, ylabel, xlim[0], xlim[1]) + plotdata + "\nEOF" )[0]



def strip(s):
	s = re.sub("\s+", " ", s)
	return s.strip()


#plotpath = "/Users/yannickulrich/Documents/code/topdrawer/topdrawer/asy.top"
#basepath = os.path.abspath(os.path.dirname(sys.argv[0]))
#plotpath = sys.argv[1]

basepath = os.path.abspath(os.path.dirname(sys.argv[0]))
#plotpath = sys.argv[1]
plotpath = basepath + "/topdrawer.top"

with open(plotpath) as fp:
	td = fp.read()

#plotdata  =                    re.findall("SET ORDER X Y DY([\s\d\.E+-]+)", td)
#plotnames = [strip(i) for i in re.findall("\s+TITLE TOP[^\"]+\"([ \S]+)"  , td)]
#ylabels   = [strip(i) for i in re.findall("TITLE LEFT \"(.+)\""           , td)]
#xlabels   = [strip(i) for i in re.findall("TITLE BOTTOM \"(.+)\""         , td)]
#xlims = [[float(j) for j in i] for i in re.findall("SET LIMITS X\s+([\d\.Ee-]+)\s+([\d\.Ee-]+)", td)]

plotZones = td.split("NEW PLOT")

html = """<!DOCTYPE html>
<html lang="en">
    <body>
	"""
for plot in range(len(plotZones)-1):
	plotdata = re.findall("SET ORDER X Y DY([\s\d\.E+-]+)", plotZones[plot])[0]
	plotname = strip(re.findall("\s+TITLE TOP[^\"]+\"([ \S]+)"  , plotZones[plot])[0])
	xlabel   = strip(re.findall("TITLE BOTTOM \"(.+)\""         , plotZones[plot])[0])
	ylabel   = strip(re.findall("TITLE LEFT \"(.+)\""           , plotZones[plot])[0])
	xlim     = [float(i) for i in re.findall("SET LIMITS X\s+([\d\.Ee-]+)\s+([\d\.Ee-]+)", plotZones[plot])[0]]
	subtext  = re.findall("TITLE [\d\.]+ [\d\.]+\s+\"(.+)\"" ,plotZones[plot])
	comments = re.findall(" \((.+)",plotZones[plot])


	#v = np.array(
	#	[[float(j) for j in i] for i in re.findall("\s+([\d\.E+-]+)\s+([\d\.E+-]+)\s+([\d\.E+-]+)",plotdata)]
	#)
	#v = [[float(j) for j in i] for i in re.findall("\s+([\d\.E+-]+)\s+([\d\.E+-]+)\s+([\d\.E+-]+)",plotdata)]
	#plt.figure()
	#plt.title(plotname)
	#plt.xlabel(xlabel)
	#plt.ylabel(ylabel)
	#plt.xlim(xlim)
	#plt.errorbar(v[:,0], v[:,1], v[:,2])
	#plt.savefig(basepath+"/plot"+str(plot) + ".png")

	html +="<h1>" + plotname + "</h1><pre>"+"\n".join(comments)+"</pre>"
	#html +="<img src=\"" + basepath + "/plot"+str(plot) + ".png\">"
	html += gnuplot(plotdata, xlabel, ylabel, xlim)
	html +="<pre>"+"\n".join(subtext)+"</pre>" 

print html
print """</body>
</html>"""
