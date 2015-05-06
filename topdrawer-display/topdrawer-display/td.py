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

	relError = [
		abs(float(i[1]) / float(i[0])) if float(i[0]) != 0 else -1 for i in 
		re.findall("\s+[\d\.E+-]+\s+([\d\.E+-]+)\s+([\d\.E+-]+)",plotdata)
	]
	relError = [i for i in relError if i != -1]


	html +="<h1>" + plotname + "</h1><pre>"+"\n".join(comments)+"</pre>"
	html += gnuplot(plotdata, xlabel, ylabel, xlim)
	html +="<pre>"+"\n".join(subtext)+"</pre>"
	html +="<pre>"
	html +="Highest relative error: " + str(100*max(relError)) + "%\n"
	html +="Smallest relative error: " + str(100*min(relError)) + "%\n"
	html +="Mean relative error: " + str(100*sum(relError)/len(relError)) + "%\n"
	html +="</pre>"

html = html+"""</body>
</html>"""
print html
