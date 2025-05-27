
#let metadata = toml(".metadata.toml")
#set document(
  title: metadata.title,
  author: metadata.author,
)

#align(center, [
  #heading(outlined: false, [
		#metadata.title
	])

	\

	#columns(2, [
		By

		#metadata.author

		#metadata.mail

		#colbreak()

		With

		Luleå University of Technology

		#metadata.company
	])

	#align(horizon, text(size: 48pt, fill: red)[
		`DRAFT #1`
	])
])

////////////////////////////////////////////////////////////////////////////////
// Preface

#let TODO(msg) = {
	[#text(fill: red, weight: "bold")[TODO: #msg]]
}
#set text(size: 12pt)
#set par(justify: true)
#set quote(block: true, quotes: true)
#show quote: set align(center)
#set math.equation(numbering:"(1)")

// Adds zero-padded line numbers to code blocks
#show raw.line: it => {
	let no = str(it.number)
	let pad = str(it.count).len() - no.len()
	text(fill: gray)[#{
		pad * "0" + no
	}]
	h(0.5em)
	it.body
}

#pagebreak(to: "even")
#align(center, [
	[This page intentionally left blank]
])
#pagebreak()

#heading(numbering: none, outlined: false, bookmarked: true, "Abstract")
// Offer a brief description of your thesis or dissertation and a concise summary
// of its conclusions. Be sure to describe the subject and focus of your work with
// clear details and avoid including lengthy explanations or opinions.

#TODO("")

*Keywords*: time series, matrix profile, anomaly detection, edge computing


#heading(numbering: none, outlined: false, bookmarked: true, "Preface")
// A preface is a statement of the author's reasons for undertaking the work and
// other personal comments that are not directly germane to the materials presented
// in other sections of the thesis.

#TODO("this paper and thanks")

- #metadata.author, \
	Luleå University of Technology, 2025


#pagebreak()
#heading(numbering: none, outlined: false, bookmarked: true, "Glossary")

#set terms(separator: ": ")
// Introduction
/ Industry 4.0: #TODO("")
/ Internet-of-Things: #TODO("")
/ Edge: #TODO("")
// Theory
/ Anomaly: An unexpected, non-conforming point or pattern in data.
/ Outlier: Common synonym for _anomaly_ in the context of data analysis.
/ Discord: An anomalous subsequence with the largest distance to neighbours.
/ Matrix Profile: A vector of calculated Euclidean distances between subsequence parts of a time series.
/ DAMP: Discord Aware Matrix Profile, an efficient algorithm for calculating a Matrix Profile.
// Method
/ $I^2C$: Inter-integrated circuit, a simple, serial communication bus.

#pagebreak()
#heading(numbering: none, outlined: false, bookmarked: true, "Contents")
#outline(title: none, indent: 2em)
#pagebreak()
#set heading(numbering: "1.1")
#set page(
	numbering: "1",
  footer: context [
    #counter(page).display("1")
    #h(1fr)
    #set text(9pt)
    #metadata.author
  ]
)

////////////////////////////////////////////////////////////////////////////////

= Introduction <introduction>

With the shift towards Industry 4.0 @lasi, the manufacturing industries are
facing new challenges as they move towards decentralised processes.
This move is partly enabled by the advances with smart devices and the rise of
the Internet-of-Things.
By increasing the use of smart sensors a manufacturer can better supervise the
operation of their equipment and, for example, better predict equipment failure.

As _Khan et al._ notes @khan, sensors and programmable logic controllers (PLCs)
are becoming the largest group of devices that generates the most data.
And as the industries scales up their sensor networks there is an increasing need
to be able to faster process the larger amounts of data,
in order to provide real-time analysis. 

This bachelor thesis will explore the use of anomaly detection on time
series data, performed on hardware-limited devices closer to the Edge.
This is an attempt at evaluating the possible usefulness of running data analysis
directly on smart sensors.
The method of anomaly detection will revolve around the Matrix Profile,
as introduced by _Yeh et al._ @yeh,
which is a family of algorithms used for detecting discord anomalies,
among other uses.
They also note that "time series discords are known to be very competitive as
novelty/anomaly detectors."

The Matrix Profile is a simple algorithm with claims of being easily scale-able
@yeh and as such might offer a more performant alternative to machine learning
models or other artificial intelligence solutions that are popular as of today.
And since it does not require a heavy processing model, it might be able to run
on smaller devices and sensors that lacks the required processing power for
running the heavier AI models.


== Motivation

Today the world is experiencing its fourth industrial revolution.
If the use of electricity and digitisation pushed the two previous revolutions
in the manufacturing industry,
then today's shift is mainly driven by the large amount of smart, modular, and
highly connected devices that forms the so called Internet-of-Things.
Dubbed as "Industry 4.0" by the team of german scientists _Dr. Lasi et al._
@lasi,
this new revolution originated from the need of increased flexibility and better 
efficiency in production systems, in order to better handle quickly shifting
market demands.

_Dr. Lasi et al._ continues in their article with, that technology is pushing 
towards miniaturisation, digitisation, automation, and as a result,
turning today's manufacturing plants into tomorrow's "smart factories".
These factories are utilising a growing number of sensors and digital, decentralised
systems that allows the factories to become more autonomously monitored and
controlled remotely.

_Javaid et al._ @javaid also notes an increasing need of intelligent sensor
systems and networks for the smart factories.
By using autonomous sensors with higher processing capabilities,
the industry will be able to reduce their dependency on human operators and thus
reduce problems caused by the human factor, for example. 
And with the availability of wireless sensors, monitoring can be done more easily
for inaccessible locations such as remote or hazardous areas.
The maintenance of the increasingly complex systems can also benefit
as more precise detection can send alerts sooner for any failing components and
thus reduce costly maintenance downtime during production.

Of course, with increasingly larger sensor networks it also follows that there is
an increasing amount of data, as mentioned by _Javaid_.
And more raw data requires communication networks with higher processing capacity.
_Gungor et al._ @gungor suggests that the sensors should filter their data and
only send the processed data, as a step towards reducing the network overhead.
Doing so also has the possible benefit of reducing signal interference, delays,
and other anomalies, caused by faulty components or simply by the environment's
wear and tear that degrades the sensors over time.
In a later section, _Gungor_ continues with a simplified outline of a basic sensor
and notes that "... local data processing is crucial in minimizing power
consumption ...".
This has the potential of extending the lifetime of the sensors that runs on
battery, or similarly limited power sources, as well as reducing the operational
costs.

Given that sensor readings are most often timestamped and thus temporal in nature
as stated by _Gupta et al._ @gupta,
the focus should be on ensuring that the time series maintains its "temporal
continuity" during the data analysis.
It should flag any sudden anomalies or other kinds of observed outliers in the
time series.


== Problem definition <definition>

This thesis looks to investigate and try to answer the following questions:

- Is it possible to calculate a Matrix Profile using raw samples from a sensor,
	in a limited hardware environment such as a small, of-the-shelf microprocessor
	board?

- Is anomaly detection accurate enough, when using a Matrix Profile?
	A comparison with a reference implementation should validate the results.

- Is the method performant enough to handle multiple sensors in the same
	environment? How efficient is the algorithm?
	A benchmark should measure the performance.

Positive outcomes to these questions would give an indication that data analysis
is possible to do on Edge devices directly.
Doing so should enable more efficient data monitoring, with earlier anomaly
detection, less data to store, and using less network traffic. 
Minimising both data storage and network traffic should help reduce the overall
amount of spent resources, required for operating larger sensor networks.

And by reducing the continuous data stream from an individual sensor, to only
have it sending out alerts, it might be possible to extend the sensor's lifetime.
This is especially true if the sensor is running on battery power.


== Delimitations

Due to the limited time available to write a bachelor thesis, this one will
constrain itself to only analyse the application of the Matrix Profile algorithm
for detecting anomalies, rather than comparing it to other methods which previous
surveys already have done extensively.

Also, the thesis will only explore the use of a single off-the-shelf device
such as a Raspberry Pi and a small set of simple sensors such as temperature,
humidity and light level.
Any other, more advanced devices are simply too expensive and possibly too time
consuming to work with.


== Thesis structure <structure>

The rest of the thesis has its structure organised in the following way.
@background introduces the theory and commonly used methods for anomaly detection.
@method walks through the implementation of a Matrix Profile, adapting it to
handle streaming data and then running it in a hardware environment with sensors.
The section continues with the data collection from the sensors and the results
are then documented in @results.
@analysis provides an analysis of the results, with a final conclusion given in
@conclusion.


////////////////////////////////////////////////////////////////////////////////

= Background and related work <background>

Anomaly detection is a broad area and there exists many, detailed studies on this
subject from the last two decades @wang, @boniol.
But what is anomaly detection? _Chandola et al._ @chandola offers a definition:

#quote[
	Anomaly detection refers to the problem of ﬁnding patterns in data 
	that do not conform to expected behaviour ...
	[which] translate to signiﬁcant, and often critical, actionable
	information in a wide variety of application domains.
]

Being able to find these non-conforming behaviours and patterns in all kinds of
data is useful indeed.
Any applicable context that have some kind of continuously, periodic data readings
involved can benefit from anomaly monitoring and detection,
to prevent problems cropping up in the future.


== Applications and challenges

Lets illustrate with a few example applications that are commonly used in the
literature @chandola, @gupta:

- Network intrusion:
	A network and its local resources such as servers, data repositories and even
	users, can have its traffic monitored to prevent the unauthorised use of or
	access to critical components such as private data or administrator users.
	Common problems in this domain involves being able to handle the large amount
	of streaming data generated from, for example, data traffic that can cause
	false alarms.
	
- Fraud detection:
	Here the goal is to detect any criminal activities from users that are looking
	for ways to fraudulently collect any resources with economical benefits,
	from other users or companies such as banks or insurance agencies.
	For example, sudden bank transfers made by an individual inside a company could
	look like an anomalous pattern from their normal behaviour,
	indicating a potential insider trader, and analysis should flag it as such.
	
- Medical and public health monitors:
	Medical symptoms or diseases can be detected and tracked by using medical data,
	either from patient records or attached health sensors.
	For example, it is common to monitor a patient's condition over time
	or tracking the outbreak of diseases in specific areas such as cities.
	In this scenario, not being able to detect anomalies in the patient's data could
	have fatal results.

- Industrial damage monitoring and sensor networks:
	Monitoring the wear and tear on industrial equipment allows for taking preventive
	action that can minimise the costs of service interruptions or equipment failures.
	Most often this requires running analysis on online, streaming data from sensor
	networks, for example, in order to detect the anomalies in a quicker manner.

But detecting non-conforming patterns in data is a difficult problem.
_Chandola_ have also noted a set of challenges associated with classifying any
observed patterns:

- It is hard to distinguish noise in the data from true anomalies, as they can
	show similar-looking patterns.
- It is hard to draw a clear boundary between what is a normal or anomalous pattern,
	while covering all possible normal cases.
- A set of patterns considered as normal behaviour at the present time can fail
	to cover any future patterns, due to evolving conditions.
- Different application domains have different anomalous patterns and thus it is
	not easy to apply a single set of normal patterns on multiple domains.

_Gupta et al._ @gupta notes a few more challenges:

- The scale of the data can be large in streaming data scenarios, thus requiring
	better processing capacity.
- Distributed scenarios requires more communication and thus also requires better
	processing capacity.
- Are there any data available with examples of anomalies, which an analysis model
	can train on?

These challenges then most often result in specific solutions for
finding anomalies in a single domain.
It has previously been common to use various kinds of machine learning models,
for example:
neural networks, support vector machines (a linear classification model),
decision trees (a rules-based prediction model),
k-nearest neighbour (a distance based model), 
DBSCAN (a clustering model),
or any mix of multiple models.
But these models have shared problems of requiring extensive training data before
being able to run data analysis, which might require human supervision.
The models could also be too computation heavy for running in
resource-constrained environments, such as small devices and sensors.


== Types of anomalies

Yet another challenge is how to define what is an anomalous pattern.
Most often it is some kind of outlier that clearly differentiates itself from
the other data, but it could also be more subtle issues that is harder to spot.
A definition that is commonly used in the literature @chandola, @gupta
and summarised by _Lai et al._ @lai:

- Point anomalies:
	Individual data points with extreme values that make them stand out
	from all other points in the data.
	These are the most simplest to detect and have been the largest focus in
	previous research.

- Contextual anomalies:
	These are also individual data points but with values that make them stand out
	in a local context (and is thus subjective), instead of globally.
	It is considered a harder problem to identify this kind of anomaly.

- Collective anomalies:
	A subsequence of data points which individually might not stand out
	but as a group they could differentiate themselves from the rest of the data
	series.

@anomalies illustrates these three types of anomalies.

#figure(
	image("images/example-anomalies.png", width: 100%),
	caption: [
		Examples of anomalies in a sine wave.
	]
) <anomalies>


== Detecting discord anomalies <detectdiscords>

One way of detecting anomalies in time series data is possible by looking for
*discords* in the time series, which _Yeh et al._ @yeh defines as
"the subsequences that has the maximum distance to its nearest neighbours."

In their paper, _Yeh_ introduces a novel algorithm called the _Matrix Profile_
which can find these discords and give strong indications of anomalies in a time
series.
The Matrix Profile produces a form of metadata array that, in simplified terms,
represents the minimal Euclidean distances between each subsequence $s$,
of size $m$, in the analysed time series _ts_.
Then it is just a matter of finding the largest distance for each subsequence,
in order to discover any possible discord anomaly.
A larger distance, _the discord score_, means that the subsequence is an unusual
pattern in the data and that there is a lower probability of a duplicate.
_Yeh's_ paper contains more in-depth definitions and details of the original
algorithm which is not repeated here for brevity, but later sections will provide
practical examinations of an improved algorithm.

Lets instead take a look at what kind of results the Matrix Profile can produce.
@examplepoint demonstrates the result after having run the algorithm on a time
series.
The data used in this example is the atmospheric pressure recorded by IRF Kiruna
@irf, during January the 15th in 2022, and it contains two noticeable pressure
drops after the 1000'th and 1500'th marks.

#figure(
	image("images/example-point.png", width: 90%),
	caption: [
		Two sudden drops in atmospheric pressure measured at IRF Kiruna (top),
		as indicated by the Matrix Profile (bottom).
	]
) <examplepoint>

The two drops was caused by the passing pressure waves from the Hunga
Tonga--Hunga Haʻapai eruption
#footnote[https://en.wikipedia.org/wiki/2022_Hunga_Tonga%E2%80%93Hunga_Ha%CA%BBapai_eruption_and_tsunami]
during this day.
The Matrix Profile was able to detect both events in the time series, as indicated
by the two tallest discord peaks.
And as the two drops are observable by eye in this scenario it is easy to verify
that the Matrix Profile works as intended.

It is also worth pointing out that the time series is small, about 2600 data points
recorded at one minute intervals, and any other, alternative tools can handle
this analysis in a reasonable time.
But what if the scale was increased to millions of data points?
This is possible with factory machines equipped with high-performance sensors
that can record samples at KHz or MHz frequencies, for example.
Since _Yeh_ published their implementation in 2017, it has seen further improvements
and there are new alternatives that can handle larger scales of data,
as discussed in the next section.


== Discord Aware Matrix Profile

Also known as DAMP, this is a new alternative implementation of the Matrix
Profile by _Lu et al._ @lu, with a focus on discovering discord anomalies in
large scales of either batched or streaming data.
_Lu_ achieves this higher performance by calculating an approximate Matrix Profile
from each subsequence's distance to all _previous ones only_, in a backwards
processing manner.
Only having to process previous data results in the space complexity of $O(n)$
and the time complexity for the worst-cases would be $O(n log n)$, although _Lu_
claims that the effective time complexity would be better in 99% of the cases due
to the algorithm being able to quit early.

@examplepattern shows an example of a time series based on simulated sensor data
from a milling machine.
In this example it is harder to observe, by eyes only, the beginning of the
anomalous pattern.
More importantly, detection needs to be fast enough to stop the milling process
sooner and avoid damaging the equipment.
And although this was a simulated scenario, as provided by the paper by _Lu_,
it serves as a good reference for later improvements of the DAMP algorithm.

#figure(
	image("images/example-pattern.png"),
	caption: [
		Readings @lu from a vibration sensor attached to a milling machine (above)
		during 3 minutes. 
		Near the end the machine starts cutting into other parts of the equipment
		and generated a tall discord peak in the profile (bottom).
	]
) <examplepattern>

@dampalgo shows pseudocode for the DAMP algorithm.
The function calculates the Matrix Profile of the analysed time series $t$,
with the subsequence length $m$ and a split point $p$, and
is temporarily kept in the $a m p$ array, which the function returns to the user
at the end.

The first loop calculates the initial scores for the first points in the time
series, _after_ the split point between the "training sequence" in the beginning
of $t$ and the points afterwards.
The training sequence acts as a warm up for the algorithm, so it does not produce
erroneous values that might skew the following scores.
The MASS v2 function finds the scores by calculating the Euclidean distances
between the subsequences, it is shown later in @massv2.

#figure(```go
func DAMP(t []float64, m int, p int) []float64 {
	amp := make([]float64, len(t)) // An new empty array

	// Find the discord scores for the first points
	for i := p-1; i < p+m; i++ {
		query := t[i: i+m]
		amp[i] = massv2(t[0: i], query)
	}
	bsf := max(amp) // The best-so-far score

	// Find scores for the rest of t
	for i := p+m; i < len(t)-m+1; i++ {
		amp[i], bsf = processBackward(t, m, i, bsf)
	}

	// Output full matrix profile of t
	return amp
}
	```, caption: [The DAMP algorithm, simplified.],
) <dampalgo>


The second loop then iterates through all subsequences in the time series and
calculates their distance profiles using the _processBackward_ function,
shown in @backproc.

_processBackward_ finds the distance scores by looping backwards in an expanding
search from the current subsequence $t_(i:i+m)$ and stops as soon as it either
reaches the beginning of $t$ _or_ when the score is lower than the best-so-far
$b s f$.
To prevent reading non-existing data, the process has to consider the two special
cases _one_ and _two_, which guards against reading data past either
possible end of the time series.
Case one will also end the loop despite what the current score would be, as there is
simply no more data that needs to be process afterwards.

The rest of the code is self explanatory.

#figure(```go
func processBackward(t []float64, m int, i int, bsf float64)
(float64, float64) {
	size := nextpower2(8 * m)
	query := t[i: i+m]
	score := math.Inf(0) // Positive infinity
	exp := 0
 
	for score >= bsf {
		start := i - size + (exp*m) + 1
		stop := i - (size/2) + (exp*m) + 1

		// Case 1: the segment furthest from the current subsequence
		if start < 1 {
			score = massv2(t[0: i+1], query)
			if score > bsf {
				bsf = score
			}
			return score, bsf
		}

		// Case 2: the segment closest to the current subsequence
		if exp == 0 {
			stop = i+1
		}

		// Get current distance score and expand the search (if needed)
		score = massv2(t[start: stop], query)
		size *= 2
		exp += 1
	}
	return score, bsf
}
```, caption: [DAMP backward processing.]) <backproc>

By halting the search as soon as a distance score is lower than the best-so-far,
the algorithm also solves the "twin-freak" problem.
An anomaly will cancel out itself if it appears more than once (hence the name
"twin-freak", from _Lu et al._) as the nearest neighbour would be itself during
the calculations of the distance scores.


== Distance between neighbours

Searching for the nearest neighbours is originally done using MASS v2 function,
which was created by _Zhong et al._ @mueen.
@massv2 displays the core equation

$
	D(t, s) = sqrt(2*(m - (p_[m:n] - m * mu_y*mu_x[m:n]) / (sigma_y*sigma_x[m:n])))
$ <massv2>

which uses a standard score
#footnote[https://en.m.wikipedia.org/wiki/Standard_score]
to normalise the distances and where $t$ is the time series so search through,
$s$ the investigated subsequence and (using common functions available in Matlab)

#align(center)[
	$m &= "length"(s), && n &&= "length"(t) \
	mu_ s&= "mean"(s), && mu_t &&= "movmean"(t, m-1) \
	sigma_s &= "std"(s), && sigma_t &&= "movstd"(t, m-1)$.
]

$s$ is then reversed and padded with zeroes until its the same size as $t$ using

#align(center)[
	$q &= "flip"(s) \
	q_[m+1:n] &= 0$
]

which is then multiplied with $t$ by the convolution of the fast Fourier
transforms #footnote[https://en.wikipedia.org/wiki/Fast_Fourier_transform],

#align(center)[
$p &= "ifft"("fft"(t) convolve "fft"(q))$
]

which is then finally inserted in @massv2.
The result is an array of Euclidean distances for the subsequence $s$ and its
neighbours in the time series $t$.

It is also noteworthy that the MASS function operates more efficient if the
amount of data points is a power of two, as mentioned by _Lu_ @lu.
If not, the function would have a significant drop in performance.
The DAMP algorithm avoids this issue by setting the size of the processed data
to the next power of two that occurs after the subsequence size,
near the beginning of the _processBackward_ function in @backproc.

As a final note, normalised distances are not wanted in some cases, for example
when trying to detect point anomalies.
Rather than using MASS, it is possible to use a generalised method such as
Minkowski's distance #footnote[https://en.wikipedia.org/wiki/Minkowski_distance]

$ D(t,s) = sqrt(sum_(i=1)^n |t_i-s_i|^2 ) \ $<minkowski>

and where $t = (t_1, t_2, ..., t_n)$ and $s = (s_1, s_2, ..., s_n)
in RR^n$.
It will also calculate the Euclidean distances more efficiently as the equation
does not involve complex numbers or temporary arrays.

The _processBackward_ function in @backproc can easily replace all its calls to
MASS with this new distance function.
As a later section will show, the loss of precision in the distance scores are
negligible when detecting point anomalies and offers great improvements in
performance.


== A note on subsequence and training sizes

As _Chandola et al._ have noted @chandola, one difficulty with anomaly detection
is choosing the most optimal size of subsequence for the analysis.
Most other studies seem to pass over this problem.
_Lu et al._ simply states that the size should be set according to domain
knowledge of the analysed time series @lu.
Though they do try to solve the problem in a later work @lu2, by analysing a time
series using _multiple_ subsequence sizes and avoid having the user pick one
themselves.

Similar difficulties exists with picking the training sizes and there is a more
noticeable lack of suggestions in the existing literature.
Although the size of the training data might have a lesser impact on the results,
in comparison with the effects of subsequence sizes.

This thesis have not investigated these parameters any further, to limit the
scope and to remain on topic, but future works might want to study the impacts
of these parameters.
For now though, the subsequence size should be "large enough" to cover the
theoretical size of any expected anomaly patterns and the training size should
be at least twice of that.


////////////////////////////////////////////////////////////////////////////////

= Method <method>

_Lu et al._ have provided an example of their DAMP algorithm in the form of a
Matlab file, as a complement to their paper @lu.
Running that example produced the raw data used for creating the plot in
@examplepattern, as shown previously.
Both the data for the time series and the corresponding Matrix Profile was then
kept as a reference dataset used for verifying future implementations. 
@app-repo contains a link to the repository that stores this dataset.

The original DAMP algorithm was then implemented in Go
#footnote[https://go.dev/] as outlined in @dampalgo and @backproc.
Go is famously known for its simple syntax and large standard library,
which lends itself well to the purpose of making quick but production-ready prototypes.
This, along with this author's previous experiences and familiarity, was the reason
for selecting Go for the practical aspects of this thesis and provides both
a stable environment and an alternative to Matlab.

The Go implementation also includes a complementary test suite which verifies,
against the reference data, the correctness of the implemented algorithm.
@results will later go into details of these results and provide an expanded analysis.


== Adapting the algorithm

As @introduction previously mentioned, the DAMP algorithm should run in a live
scenario and be able to handle live sensor data.
The original algorithm would produce a Matrix Profile contained in a data array
that is of equal size as the in-data, so appending new in-data would then grow
the output array.
Eventually the computer would either run out of memory, when it fills up with
the arrays, or reprocessing the increasingly larger in-data array would consume
too much time and energy to be of any practical use in a live scenario.

In order to handle this scenario, the Go implementation must be adapted to handle
continuously arriving data without running out of computing resources.
_Lan et al._ suggests @lan, as a basic strategy, to use a cache of any sort and
limit the amount of data processed.

_Gillis_ offers a simple to use double-ended queue in Go @gillis and it can
operate as an efficient first-in, first-out (FIFO) queue, as illustrated in @deque.
It is worth noting that as it keeps track of both ends, it is able to operate in
$O(1)$ time when pushing to or popping from respective end.
And the internal buffer is always a power of two too, so this data structure fits
in well with the MASS function and its requirements, as has been previously explained.

// pkg source: https://typst.app/universe/package/fletcher
#import "@preview/fletcher:0.5.7" as fletcher: diagram, node, edge
#figure(
	diagram(
	  // debug: 1,
	  node-stroke: 1pt,
	  node((-0.8,0), " ", shape: rect),
	  node((-0.4,0), " ", shape: rect),
	  node((0,0), "0", shape: rect),
	  node((0.4,0), "1", shape: rect),
	  node((0.8,0), "2", shape: rect),
	  node((1.2,0), "3", shape: rect),
	  node((1.6,0), "4", shape: rect),
	  node((2.0,0), "5", shape: rect),
	  node((2.4,0), " ", shape: rect),
	  node((2.8,0), " ", shape: rect),
	  edge((0,1), (0,0), "-|>", [Front]),
	  edge((2,1), (2,0), "-|>", [Back]),
	  edge((-2.8,0), (-0.8,0), "<|-", [PopFront()]),
	  edge((2.8,0), (4.8,0), "<|-", [PushBack()]),
	  edge((0,-0.4), (2,-0.4), "|-|", [Len()]),
	  edge((-0.8, -1), (2.8, -1), "|-|", [Capacity]),
	),
	caption: [A double-ended FIFO queue.]
) <deque>

By using this new data structure as a buffer in place of the previously used data
arrays, an alternative implementation would be able to consume streaming data in
a continuously manner.
@streamdamp shows how the queue can be utilised when calculating discord scores.

_StreamDAMP_ is a data structure that keeps two queues for the raw data and the
Matrix Profile, and other associated values such as data sizes and a best-so-far
score.
The new function _Push_ will add a raw value to the data queue, making sure it
does not overflow, and then call _processBackward_ to calculate the discord score
in a similar manner as previously shown in @dampalgo.
The score is kept in the internal Matrix Profile for future calculations
and is then finally returned back to the user.

#figure(```go
func Push(sd *StreamDAMP, value float64) float64 {
	if sd.data.Len() == sd.maxSize {
		// Queue is full, free up a new slot and find new best-so-far score
		sd.data.PopFront()
		sd.amp.PopFront()
		sd.bsf = sd.amp.Max()
	}

	sd.data.PushBack(value)
	if sd.data.Len() < sd.trainSize {
		// Wait for more training data before running calculations
		sd.amp.PushBack(0)
		return 0
	}

	// Find the discord score for the new value
	index := sd.data.Len()-sd.seqSize
	score, sd.bsf := processBackward(sd.data, sd.seqSize, index, sd.bsf)
	sd.amp.Push(score)
	return score
}
```, caption: [Function for continuously pushing new data to DAMP.]) <streamdamp>
// ```, caption: [The DAMP algorithm adapted to handle streaming data.]) <streamdamp>

A user can now repeatedly call _Push_ whenever new data is collected, for example
from a data stream from a sensor, and perform analysis and monitoring in real time.
And thanks to the double-ended queue acting as a buffer, most Edge devices
(with limited computing resources) should be able to handle large amounts of data
with ease.
The following subsections will explore this and then @results will present the
results.

== Setting up hardware environment

Running the adapted DAMP algorithm in a live-test scenario requires the setup of
a hardware environment.
This thesis uses cheap, consumer-grade devices that can be commonly found
off-the-shelf and the bill of materials includes:

- *Raspberry Pi 4, model B with 1GB RAM
#footnote[https://www.raspberrypi.com/products/raspberry-pi-4-model-b/specifications/]
.* \
	It is versatile enough and allows for running high-level programming languages,
	thus not restricting the user to work with closer-to-the-metal environments such
	as with assembly or plain C programming. Saves a great amount of time.

- *Environment Sensor HAT, by Waveshare
#footnote[https://www.waveshare.com/wiki/Environment_Sensor_HAT]
.* \
	This is an addon module equipped with a TSL25911 ambient light sensor, a BME280
	temperature, humidity, and air pressure combination sensor, a ICM20948
	gyroscopic motion sensor, an LTR390-UV-1 ultraviolet (UV) sensor, and finally
	a SGP40 volatile organic compound (VOC) sensor.
	Many alternative sensors provided in a single package.

Setting up the hardware required using some wires and a breadboard which is
commonly used when prototyping electronic projects, as shown in @hatonrasp.
@app-wiring have a wiring diagram that better illustrates the setup.
The Raspberry Pi was then powered up and setup in a default way by following the
getting started guide @raspberry and then connected to a locally available WIFI
network.

#figure(
	block(clip: true, radius: 4pt, image("images/photo-rasp-sensor.jpg", width: 75%)),
	caption: [Environment sensor HAT mounted on Raspberry Pi.],
) <hatonrasp>

InfluxDB was then installed in a similar way by following its setup guide @influxdb.
InfluxDB is a simple to use time series database with a built in data explorer.
It is a suitable choice for monitoring the Raspberry Pi's performance and logging
both raw sensor data and corresponding Matrix Profiles.

Finally, Telegraf was installed @telegraf.
It is a monitoring agent that can collect various statistics such as memory usage,
CPU times and other performance-related data from the Raspberry Pi.
The collected data is then sent to InfluxDB for logging and monitoring purposes.
@app-telegraf shows the configuration file used for Telegraf.


== Logging sensor data <logger>

With the hardware set up and ready, the stream-adapted DAMP implementation could
start processing the sensor data.
@lightsensor shows example code for collecting the shifting, ambient light level
from the TSL25911 sensor.
The code is running continuously on the Raspberry Pi in order to log the data
for later analysis.
Please note that any error handling was omitted for brevity.

Line 05 sets up an instance of the streaming DAMP algorithm, which can continuously
calculate the Matrix Profile of the sensor data.
Line 09 and 23 creates instances for the sensor driver and writable client for
InfluxDB, respectively.
The block spanning lines 26-35 then runs an infinite loop, with an iteration
once per second, that reads the current light level and calculates the latest
discord score from the Matrix Profile.
Both values are then sent to InfluxDB for storage and analysis.

#TODO("update with new code")

#figure(```go
// Initialise DAMP
sequenceSize := 600 // in seconds (10 minutes)
queueSize := sequenceSize * 3
trainingSize := sequenceSize * 2
sdamp := damp.NewStreamingDAMP(queueSize, sequenceSize, trainingSize)

// Initialise sensor device driver provided by:
// github.com/JenswBE/golang-tsl2591
sensor := tsl2591.NewTSL2591(&tsl2591.Opts{
	Gain:   tsl2591.GainLow,
	Timing: tsl2591.IntegrationTime100MS,
})

// Initialise influxdb client using the official client:
// github.com/influxdata/influxdb-client-go/v2
host := "http://localhost:8086/"
token := "super secret API token"
organisation := "example org"
bucket := "example bucket"
client := influxdb2.NewClientWithOptions(
	host, token, influxdb2.DefaultOptions(),
)
writer := client.WriteAPI(organisation, bucket)

// Collect sensor data and Matrix Profile in a loop
for {
	value := sensor.Lux()
	discord := sdamp.Push(value)
	point := influxdb2.NewPointWithMeasurement("light").
					 AddField("current", value).
					 AddField("discord", discord).
					 SetTime(time.Now())
	writer.WritePoint(p)
	time.Sleep(1 * time.Second)
}
```, caption: [Example for collecting data from the TSL25911 ambient light sensor.],
) <lightsensor>

@bmesensor illustrates a similar example for collecting data from the BME280 device
which has multiple built-in sensors.
Lines 04-12 connects to the $I^2C$ bus the devices communicates over and disables
all sensor filters.
Lines 18-20 then reads the raw values from the three sensors and normalises them
to more manageable units.
Lines 23-25 calculates discord scores as usual, but using individual instances
of the Streaming DAMP algorithm.
The initialisation of these instances was similar to the setup done in @lightsensor,
but was again omitted for the sake of brevity.
All six values was then sent to InfluxDB.

#TODO("update with new code")

#figure(```go
// Initialise new sensor driver provided by:
// periph.io/x/devices/v3/bmxx80
// and all its associated libraries.
host.Init()
bus := i2creg.Open("")
address := 0x76
sensor = bmxx80.NewI2C(bus, address, &bmxx80.Opts{
	Temperature: bmxx80.O1x,
	Pressure:    bmxx80.O1x,
	Humidity:    bmxx80.O1x,
	Filter:      bmxx80.NoFilter,
})

var env physic.Env
for {
		// Collect new data readings from the various sensors
		sensor.Sense(&env)
		temp := env.Temperature.Celsius()
		pres := float64(env.Pressure) / float64(physic.Pascal)
		humi := float64(env.Humidity) / float64(physic.PercentRH)

		// And calculate new discord scores
		tempDiscord := sdampTemp.Push(temp)
		presDiscord := sdampPres.Push(pres)
		humiDiscord := sdampHumi.Push(humi)

		point := influxdb2.NewPointWithMeasurement(...)
		writer.WritePoint(p)
		time.Sleep(1 * time.Second)
}
```, caption: [Example for collecting multiple values from the BME280 combination sensor.],
) <bmesensor>

Both examples was then merged into a single utility, the sensor "logger".
It could then run in the background on the Raspberry Pi and continuously
collect the sensor samples and discord scores for InfluxDB. 

More sensors were available of course, the gyroscopic/UV/VOC devices, which were
not used.
The VOC sensor did not have a ready-made driver in Go available at the time
and the UV and gyroscopic sensors did not provide any interesting data.


== A note on signal noise

One important detail that have not been mentioned before is how DAMP will handle
fluctuating data and other problems associated with signal noise.
The subject itself is a well-known problem and it is common knowledge that if a
signal input contains noise, the output result will also contain noise or worse.
This remains true for DAMP of course.

As an example, a basic low-pass filter could filter the data before it is pushed
into DAMP and remove the noise in the higher frequencies.
This was dismissed as being out of scope though, as it would require a lot more
time and studies in advanced courses not available for a bachelor's degree.
And as the results in the following section suggests, the noise might not affect
DAMP too much anyway.

// @book{vaseghi2008advanced,
//   title={Advanced digital signal processing and noise reduction},
//   author={Vaseghi, Saeed V},
//   year={2008},
//   publisher={John Wiley \& Sons}
// }


////////////////////////////////////////////////////////////////////////////////

= Results <results>

As was already mentioned in @method, the Matlab script authored by _Lu et al._
served as a reference for the new implementations in this thesis.
The datasets used to create the example plots in their paper @lu was also
provided on their publishing page
#footnote[https://sites.google.com/view/discord-aware-matrix-profile/dataset]
and so could be reused as test data in this work.

In the following figures in this section, the first plot shows the raw data from
a time series.
The second plot is the output from _Lu's_ Matlab script and serves as a visual
reference for the next plots.
The last three plots shows the outputs from the implementations used in this thesis.
The discord peaks in these plots should ideally line up with the peaks in the
reference plot above them.
The peaks themselves should point out the anomalies in the time series data.
All plots are kept together on a single page, to aid the comparison.

@res-milling is a constructed example by _Lu_ @lu with synthetic data that simulates
a vibration sensor on a milling machine.
After the 35000'th time mark near the end, a collective anomaly appears and discord
analysis should highlight this pattern with a peak in the discord plots.

@res-tonga shows analysis done on atmospheric pressure data collected by IRF Kiruna
@irf, over the day of January the 15th, 2022.
As @detectdiscords already explained, two pressure drops appeared in the data
as contextual anomalies after the 1000'th and 1500'th marks, and the analysis
should highlight them as such.

@res-bourke is the final example and the data represents pedestrian foot traffic
near Bourke Street Mall, in the city of Melbourne, Australia.
Multiple point and contextual anomalies appeared in the time series and most
likely represents holiday events with accompanying increase of the foot traffic.
_Lu_ provided this example along with their Matlab script,
but it was missing exact details of the source, date and any other details that
would explain the causes of the anomalies.
A web search could identify a possible source page
#footnote[https://www.pedestrian.melbourne.vic.gov.au/]
but its relevance remains unconfirmed.
This dataset served as an initial reference during prototyping and acted as a more
difficult example for the discord analysis.

A later section will analyse the results of these figures in more depth.

#figure(
	image("images/analysis-2-machining.png", height: 95%),
	caption: [
		Discord analysis of synthetic data by _Lu_ @lu, simulating a vibration sensor
		on a milling machine.
		The task was to detect the collective anomaly near the end of the range.
	],
) <res-milling>

#figure(
	image("images/analysis-3-knutstorp.png", height: 95%),
	caption: [
		Analysis of air pressure data collected by IRF Kiruna.
		The task was to detect the two contextual anomalies (caused by pressure drops).
	],
) <res-tonga>

#figure(
	image("images/analysis-1-bourkestreetmall.png", height: 95%),
	caption: [
		Analysis of pedestrian traffic on a street, as used by _Lu_.
		This final task contains multiple point and contextual anomalies.
	],
) <res-bourke>


== Benchmark <benchmark>

The discord analysis also measured the time required to process each dataset for
each implementation and stored the results.
Plotting the runtimes resulted in @res-times which is, in hindsight, an unfair
comparison.
@analysis provides more details for each method and why they produce results
that are unfair when compared to each other.

This plot serves better as a proof of validation, in that making adaptions to
the original DAMP algorithm (to handle streaming data) would allow it to run
better in limited computing environments.

#figure(
	image("images/analysis-timings.png"),
	caption: [Average runtimes for the analysis of each dataset.]
) <res-times>

A proper benchmark was done afterwards on Stream DAMP and it highlights the
differences in performance, depending strongly on the choice of method for
calculating the subsequence distances.

The benchmark used a randomly generated time series with 10240 data points.
@app-benchmarks contains the full output of that benchmark, with the results
averaged and presented in @res-bench.

#figure(
	table(
		columns: 5,
		align: left,
		inset: 6pt,
		table.header(
			[*Normalised*], [*Iterations (N)*], [*Time/Op. (ns)*], [*Memory/Op. (bytes)*], [*Allocations/Op. (N)*],
		),
		[Yes], [10000], [1626019], [1598765], [1134],
		[No], [37794], [33303], [16149], [6],
	),
	caption: "Average performance while running benchmarks for Stream DAMP on random data."
) <res-bench>


== Live sensor performance

The logger utility from @logger have been running for a week on the Raspberry Pi
and was able to collect a large amount of raw data from all sensors and their
corresponding Matrix Profiles.
The telegraf agent was also running in the background at the same time and
collected statistics on the system's overall performance.
The results was then presented in the web view of InfluxDB, as shown in @res-perf.

It is worth pointing out that this performance view
displays the resource utilisation of the whole system and all its background
services.
"System load" is an arbitrary measurement of the work load while running tasks
on the system (causing work for the CPU, hard drives, or network devices for
example) and is an average of the last 15 minutes.

#figure(
	image("images/sensors-performance.png"),
	caption: [Resource utilisation on the Raspberry Pi.],
) <res-perf>

@res-seven displays the collected sensor data for the last seven days and is an
aggregation due to the large amount of data.
The logger utility sampled all sensors in one second intervals and calculated
the corresponding discord score for each new data point, using 10 second
subsequence sizes and with normalisation turned off.
The two annotations in the plots for temperature and humidity marks the time
for when an open window caused an indoor draft for half an hour.

@res-three shows the raw sensor data and corresponding Matrix Profiles from the
last three hours.
At 09:00 a plant light was automatically turned on and is visible in the plot for
the light sensor.
A 10 minute shower after 11:00 caused a sharp increase in the humidity and a
smoother increase in the indoor temperature.

#figure(
	stack(dir: ttb, spacing: 0pt,
		image("images/sensors-1.png", width: 75%),
		image("images/sensors-2.png", width: 75%),
	),
	caption: [Sensor data and Matrix Profiles aggregated over the last seven days.]
) <res-seven>

#figure(
	stack(dir: ttb, spacing: 0pt,
		image("images/sensors-3.png", width: 75%),
		image("images/sensors-4.png", width: 75%),
	),
	caption: [Raw sensor data from the last three hours.]
) <res-three>


= Analysis <analysis>

In the beginning of the previous section, four methods analysed three datasets
with different types of anomalies in them and the results was then plotted.
An investigation of the results is now done in this section, in a bid to offer
insights into and an evaluation of the analyses.

Starting with @res-milling, the dataset was a synthetic example dense with points
that had a high variance in their range, thus producing a "thick" plot.
The anomaly is easily visible near the end but it is hard to determine when it
begins with eyes only.
A human operator would most likely not react fast enough to interrupt the milling
machine before it had already started cutting into itself.
Fast and early detection would be beneficial in this example.

As is then shown in the follow plots, all methods could correctly identify the
anomaly almost before it even started, illustrating the effectiveness of the
shared method.
However, turning of normalisation for Stream DAMP made it highlight an earlier
but minor pattern as a bigger anomaly (as indicated with the taller peak near
the beginning) and could trigger a false alarm early during the work routine.
This illustrates the importance of using normalisation in the cases for when
an anomaly consists of multiple points in some sort of a pattern, even if human
eyes can not observe it directly.

In @res-tonga, the dataset is less noisy and produced a cleaner curve in the plot,
with two harder-to-observe anomalies hidden in the middle.
Here the regular DAMP methods, with normalisation, could not provide any
meaningful results.
Turning of normalisation was the only way to correctly detect the anomalies,
as shown in the last plot.

And as the first, sprawling plots suggest, the algorithm most likely had a hard
time to find any matching patterns and had to expand its search multiple times.
The benchmark later on seems to confirm this theory, as the DAMP implementation
had a large performance degradation when compared to the two other methods.

With @res-bourke as the final example, a couple of spikes is easily seen in the
foot traffic but no other obvious patterns are visible in the plot.
All methods seems to agree on the point anomaly "spike" near the 8000'th time mark
and also for the contextual "drop" after the 16000'th mark.
A random remark is that turning of normalisation seemed to produce the most
confident result.

It is hard to provide any more meaningful observations without access to the
original source.
Although, this dataset provided great validation of having made correct
implementations, while developing the prototypes, and was mainly kept for that
purpose.


== On the benchmark <on-bench>
As was already mentioned in @benchmark, the bar plot shows an unfair comparison.
One of the reason for this is that the first DAMP implementation was naively
re-implemented from _Lu's_ Matlab script and had no optimisations done on it.
Hence why the plot would indicate that this method required so much more time to
process each new data point.
The major focus for this method was instead spent on producing results that
matched as close a possible to the reference results.

For the two other implementations, Stream DAMP had to use a double-ended queue
of a limited size so it could process new data in a streaming manner.
Using this queue would of course provide performance gains, as less data needed
to be re-processed when looking for the nearest neighbours for each new data point.

And finally, disabling normalisation allowed for using a more simpler and much
more efficient distance calculation using Minkowski's method.
In contrast to that, the MASS function was naively implemented, alongside with
DAMP, and runs much heavier operations required for the normalisation.
Obvious targets for optimisations would be the unnecessary re-allocations of the
arrays holding complex numbers, for example.

This large difference between the two distance functions was then confirmed with
the results in the benchmark table.
Using this initial benchmark, further work could investigate and measure the
performance of:

- using other methods for calculating the distances
- optimising existing methods
- or adapting Minkowski's method to also handle normalisation.

The existing streaming adaptions were good enough though and could be easily run
on the Raspberry Pi, which the following section will discuss.


== On the sensors <on-sensors>

As @res-perf shows, the load on the CPU was non-existent while running Stream DAMP
in parallel with all other system services in the background.
It is most likely the background services that is causing the most work load on
the system, as suggested from the top of the process list:

```
# sudo ps axS k -time o user,pcpu,pmem,time,comm | head -n 5
USER    		%CPU		%MEM		    TIME		COMMAND
influxdb		 1.6		28.1		03:34:42		influxd
lmas    		 0.3		 0.9		00:44:21		logger
telegraf		 0.1		10.5		00:21:55		telegraf
root    		 0.0		 1.4		00:04:10		NetworkManager
```

The resource usage numbers does not match exactly with the plot though, as the
telegraf data was missing some system overhead in the reported statistics.
The list does however highlight that InfluxDB have used the most memory and is
the most likely cause for the periodic drops in the RAM load.
This is probably due to when the service offloads its data cache when it has
grown too large.

It is interesting to see that the logger utility was able to operate with less
than one percent of the one GB RAM that was available on the system.
This suggests that Stream DAMP could run in even smaller environments, for
example on an Arduino board or any other micro-controllers.

Future work would require finding better values for the subsequence sizes though,
as the Matrix Profiles would only give strong indications for the most obvious
anomalies in the sensor samples.
The sensor drivers would also require some more work, to get rid of the noisy
spikes in the data that the Matrix Profiles likes to point out.
A final suggestion would be to set up a threshold for the discord peaks, which
could filter out the lesser discords and make the other peaks more actionable.

////////////////////////////////////////////////////////////////////////////////

// The discussion discusses each individual problem, how you addressed it, alternative solutions and shortcomings, etc.

// The conclusions and future work describes the final outcome of how you solved your problems and what is left to do.

= Conclusion <conclusion>

#TODO("")

hard to work with matlab code examples:
- one-based indexing (instead of the more common zero indexing) causing many issues
	and off-by-one errors.
- large amount of helper funcs required for performing arithmetic on arrays.
- doing a fast fourier transform required the use of complex numbers, which was
	a different type in Go and might cause performance problems.

algo:
- can not handle constant regions, causing NaNs.
- especially gyro worked poorly, as it kept to its baseline all the time.
- but one happy accident was that the new streaming algo could recover from the
	constant region problems thanks to the ring-buffer cycling through data.
- surprised the deque library did not add bad performance overhead.
- hard to pick good seq.size, need more research and detailing effects of it.

sensors:
- the choice of hardware sensors was poorly made, should had researched better.


== Future work

The most obvious area that needs more work is the subject of how to pick an
optimal subsequence size for your data source.
The subject needs a more thorough investigation, by itself, which should produce
some sort of a guideline.
This might be difficult though, as time series data and anomaly patterns varies
greatly between the different types of data sources that are available.
Alternatively, more studies could investigate _Lu's_ approach @lu2, where they
simply analyse a large amount of subsequence sizes by default.

Another area that lacks study is the choice of distance function and how it would
affect, performance wise, finding the nearest neighbours for a subsequence.
As mentioned in @on-bench near the end, one initial investigation could try
to normalise Minkowski's method and, if possible, compare it to the MASS function.

_Rakthanmanon et al._ suggest other interesting optimisations @rakthanmanon that
would be worth to investigate for this work.
For example, calculating a square root is an expensive mathematical operation on
a computer and unfortunately a required step when calculating exact Euclidean
distances.
However, skipping the square root would not affect the relation between nearest
neighbours and could offer performance improvements when running distance searches
on large sets of time series.
Another suggestion is to abort the distance search earlier by ignoring subsequences
outside of lower bounds.

@on-sensors also had suggestions for refining the raw samples from the sensors,
or reimplementing the drivers from scratch, and setting up some sort of a threshold
for filtering and ignoring smaller discord scores.
But doing so would require an adaptable threshold that could adjust itself over
time, so it could better handle variations in the time series.

////////////////////////////////////////////////////////////////////////////////

#pagebreak()
= References

#bibliography(
	"references.yml",
	style: "ieee",
	title: none,
)

////////////////////////////////////////////////////////////////////////////////

#set heading(numbering: "A.1", supplement: [Appendix])
#show heading: it => {
	if it.level == 1 and it.numbering != none {
		[#it.supplement #counter(heading).display(): ]
	} else if it.numbering != none {
		[#counter(heading).display() ]
	}
	it.body
}
#counter(heading).update(0)


#pagebreak()
= Project repository <app-repo>

#TODO("link to repo and any other instructions")

- Generate @anomalies using:

	go run experiments/generate_anomalies.go \
	./experiments/plot_anomalies.sh

- Generate @examplepoint using:

	#TODO("")

- Generate @examplepattern using:

	./experiments/plot_examples.sh
	
- Generate "TODO: PLOTS IN RESULTS" using:

		go run experiments/generate_samples.go \
		./experiments/plot_samples.sh


#pagebreak()
= Hardware wiring setup <app-wiring>

#TODO("")


#pagebreak()
= Telegraf configuration <app-telegraf>

#show raw: set text(size: 7pt)

```toml
# Configuration for telegraf agent
# https://github.com/influxdata/telegraf/blob/release-1.33/docs/CONFIGURATION.md
[agent]
  interval = "1m"
  round_interval = true
  metric_batch_size = 1000
  metric_buffer_limit = 10000
  collection_jitter = "5s"
  flush_interval = "15m"
  flush_jitter = "5s"
  precision = "0s"
  debug = false
  quiet = true
  log_with_timezone = "local"
  omit_hostname = true

#######################################################################

# Configuration for sending metrics to InfluxDB 2.0
# https://github.com/influxdata/telegraf/blob/release-1.33/plugins/outputs/influxdb_v2/README.md
[[outputs.influxdb_v2]]
  urls = ["http://127.0.0.1:8086"]
  token = "<redacted>"
  organization = "LTU"
  bucket = "host"
  timeout = "5s"
  influx_omit_timestamp = false

#######################################################################

# Read metrics about cpu usage
# https://github.com/influxdata/telegraf/blob/release-1.33/plugins/inputs/cpu/README.md
[[inputs.cpu]]
  fieldinclude = ["usage_user", "usage_system", "usage_idle"] 
  tagexclude = ["cpu"]
  percpu = false
  totalcpu = true
  collect_cpu_time = false
  report_active = false
  core_tags = false

# Read metrics about memory usage
# https://github.com/influxdata/telegraf/blob/release-1.33/plugins/inputs/mem/README.md
[[inputs.mem]]
  fieldinclude = ["used_percent"]

# Read metrics about system load & uptime
# https://github.com/influxdata/telegraf/blob/release-1.33/plugins/inputs/system/README.md
[[inputs.system]]
 fieldinclude = ["uptime", "load15", "n_users"]
```


#pagebreak()
= Performance benchmark <app-benchmarks>

```
# go test -test.benchmem -bench=. -count 10 "./damp"
goos: freebsd
goarch: amd64
pkg: code.larus.se/lmas/thesis/damp
cpu: Intel(R) Core(TM) i5-7200U CPU @ 2.50GHz
Normalised-4      10000  1622685 ns/op  1599982 B/op  1135 allocs/op
Normalised-4      10000  1624508 ns/op  1598646 B/op  1135 allocs/op
Normalised-4      10000  1631566 ns/op  1598646 B/op  1135 allocs/op
Normalised-4      10000  1623754 ns/op  1598633 B/op  1134 allocs/op
Normalised-4      10000  1626154 ns/op  1598622 B/op  1134 allocs/op
Normalised-4      10000  1627689 ns/op  1598625 B/op  1134 allocs/op
Normalised-4      10000  1626680 ns/op  1598626 B/op  1134 allocs/op
Normalised-4      10000  1625058 ns/op  1598621 B/op  1134 allocs/op
Normalised-4      10000  1625635 ns/op  1598626 B/op  1134 allocs/op
Normalised-4      10000  1626463 ns/op  1598626 B/op  1134 allocs/op
NoneNormalised-4  38035    33345 ns/op    16152 B/op     6 allocs/op
NoneNormalised-4  37266    33394 ns/op    16145 B/op     6 allocs/op
NoneNormalised-4  38080    33320 ns/op    16151 B/op     6 allocs/op
NoneNormalised-4  38044    33231 ns/op    16151 B/op     6 allocs/op
NoneNormalised-4  37311    33448 ns/op    16145 B/op     6 allocs/op
NoneNormalised-4  37657    33308 ns/op    16148 B/op     6 allocs/op
NoneNormalised-4  38005    33225 ns/op    16151 B/op     6 allocs/op
NoneNormalised-4  37348    33368 ns/op    16146 B/op     6 allocs/op
NoneNormalised-4  38059    33207 ns/op    16151 B/op     6 allocs/op
NoneNormalised-4  38136    33187 ns/op    16152 B/op     6 allocs/op
PASS
ok  	code.larus.se/lmas/thesis/damp	183.733s
```
