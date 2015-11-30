#!/usr/bin/python

import sys, urllib, json
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.mlab as mlab
from scipy.stats import norm

phrase = sys.argv[1]
granularity = sys.argv[2]
apikey = "c711d58a1c634f0aa366c21ddc4de6c7"
url = "http://capitolwords.org/api/dates.json?phrase=%s&granularity=%s&mincount=0&apikey=%s" % (phrase, granularity, apikey)

f = urllib.urlopen(url).read()
j = json.loads(f)
counts = [x['count'] for x in j['results']]
(mu, sigma) = norm.fit(counts)

print "Total: %s" % (np.sum(counts))
print "Average Mentions per %s: %s" % (granularity, mu)
print "Std Dev: %s" % (sigma)
print "Median: %s" % (np.median(counts))
print "Variance: %s" % (np.var(counts))

if granularity == "month":
	n, bins, patches = plt.hist(counts, bins=24, normed=1, alpha=0.75, facecolor='green')
	y = mlab.normpdf(bins, mu, sigma)
	plt.plot(bins, y, 'r--', linewidth=2)
	plt.xlabel('Mentions')
	plt.ylabel('Probability')
	plt.title(r'$\mathrm{Histogram\ of\ %s\ Mentions:}\ \mu=%.3f,\ \sigma=%.3f$' %(phrase.title(), mu, sigma))
	plt.grid(True)
	plt.show()
