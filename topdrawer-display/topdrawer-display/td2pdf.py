import sys,re,os
import subprocess

def ps2pdf(ps):
	proc = subprocess.Popen(["/usr/local/bin/ps2pdf", "-"], stdin=subprocess.PIPE, stdout=subprocess.PIPE)
	return proc.communicate(ps)[0]

def gnuplot(plotdata, xlabel, ylabel, xlim, text_below):
	proc = subprocess.Popen("gnuplot", stdin=subprocess.PIPE, stdout=subprocess.PIPE) #, cwd=basepath)
	return proc.communicate("""
set terminal postscript
set xlabel '%s'
set ylabel '%s'
set xrange [%f:%f]
set key off
set label 11 center at graph 0.5,char 1 "%s" font ",14"
set bmargin 5
plot "-" using 1:2:($2-$3):($2+$3) with errorbars
""" % (xlabel, ylabel, xlim[0], xlim[1], "\\n".join(text_below)) + plotdata + "\nEOF" )[0]



def strip(s):
	s = re.sub("\s+", " ", s)
	return s.strip()



basepath = os.path.abspath(os.path.dirname(sys.argv[0]))
plotpath = basepath + "/topdrawer.top"


with open(plotpath) as fp:
	td = fp.read()

td = td.replace("`", "")

plotZones = td.split("NEW PLOT")

ps = ""

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


	psPage = gnuplot(plotdata, xlabel, ylabel, xlim, subtext).split("%%Page:")
	# Add header and info page
	if ps == "": 
		infopage="""%!
/Courier findfont
12 scalefont
setfont
""" + "\n".join([ "72 " + str(700-20*i) + "  moveto\n(" +
	comments[i].replace(")","\)").replace("(","\(") 
	+ ") show" for i in range(len(comments))]) + "\nshowpage"
		ps = infopage + psPage[0]

	ps += "\n" + psPage[1]


print ps2pdf(ps)


