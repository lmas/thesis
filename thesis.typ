// Metadata

#let title = "Time series anomaly detection for edge computing devices"
#let author = "Alex TODO"
// #let date = datetime(year: 2025, month: 2, day: 17)

#set document(
  title: title,
  author: author,
  // date: date,
)


////////////////////////////////////////////////////////////////////////////////
// Title page

#align(center, [
  // #set text(16pt)
  #heading(outlined: false, [
		#title
	])

	\

	// #author
	#columns(2, [
		By

		#author

		`mail@mail`

		#colbreak()

		With

		Luleå University of Technology

		company xxx
	])
])

TODO: new title

#pagebreak(to: "even")
#align(center, [
	[This page intentionally left blank]
])
#pagebreak()

////////////////////////////////////////////////////////////////////////////////
// Preface

#set text(size: 12pt)
#set par(justify: true, first-line-indent: 1em)
#set quote(block: true, quotes: true)
#show quote: set align(center)

#heading(numbering: none, outlined: false, bookmarked: true, "Abstract")
// Offer a brief description of your thesis or dissertation and a concise summary
// of its conclusions. Be sure to describe the subject and focus of your work with
// clear details and avoid including lengthy explanations or opinions.

TODO 

#lorem(50)

#lorem(50)

#lorem(50)

*Keywords*: time series, matrix profile, anomaly detection, edge computing


#heading(numbering: none, outlined: false, bookmarked: true, "Preface")
// A preface is a statement of the author's reasons for undertaking the work and
// other personal comments that are not directly germane to the materials presented
// in other sections of the thesis.

TODO this paper and thanks

#lorem(50)

#lorem(50)

- #author, \
	Luleå University of Technology, 2025


#pagebreak()
#heading(numbering: none, outlined: false, bookmarked: true, "Glossary")

#set terms(separator: ": ")
// Introduction
/ Industry 4.0: TODO
/ Internet-of-Things: TODO
/ PLC: Programmable logic controller.
/ Edge: TODO
// Theory
/ Anomaly: An unexpected, non-conforming pattern in data.
/ Outlier: Common synonym for _anomaly_ in the context of data analysis.
/ Discord: TODO

#pagebreak()
#heading(numbering: none, outlined: false, bookmarked: true, "Contents")
#outline(title: none, indent: 2em)

////////////////////////////////////////////////////////////////////////////////
// Introduction

#set heading(numbering: "1.")
#set page(
	numbering: "1",
  footer: context [
    #counter(page).display("1")
    #h(1fr)
    #set text(7pt)
    #author
  ]
)

// - citations-15973-Anomaly Detection_ A Survey.pdf
// 	anom. detect related to noise handling, challenges with anom. detection, detailed applications, fault/defect detection, sensor networks, pros/cons
	
// - citations-01521-Outlier Detection for Temporal Data_ A Survey.pdf
// 	other scenarios than sensors, comprehensive definitions, extra focus on streaming/sliding windows/distributed systems, environ/indust sensors and other data,

// - citations-00892-Matrix Profile I_ All Pairs Similarity Joins for Time Series__A Unifying View that Includes Motifs, Discords and Shapelets.pdf
// 	original MP algo, algo definitions, quirk with window size not power of 2?  other uses than discord discovery, batch vs streams

// - citations-00632-Progress in Outlier Detection Techniques_ A Survey.pdf
// 	many usage examples, all types, distance-based scales well/flexible, pros/cons, python tools, datasets, no MP

// - citations-00311-Smart anomaly detection in sensor systems A multi-perspective review.pdf
// 	analysis on sensors, types of sensor data/anomalies,  use at the Edge, energy usage

// - citations-00184-Detecting Sensor Faults, Anomalies and Outliers in_the Internet of Things_ A Survey on the_Challenges and Solutions.pdf
// 	IoT and sensor networks, events and errors, pros/cons of nearest neighbour, different detection strategies

// - citations-00094-Detecting Anomalies in a Time Series Database.pdf
// 	"window based discords" outperform predictive/segmentation

// - citations-00003-Dive into Time-Series Anomaly Detection_ A Decade Review.pdf
// 	large overview and theories, definitions of uni-/multivariate, anomalies, method families, matrix profile finding discord


#pagebreak()
= Introduction, ~3 pages <introduction>

// The introduction gives an overview of the area of your problems.

// - Increasing amount of data generated in the industry

With the shift towards Industry 4.0 @lasi, the manufacturing industries are
facing new challenges as they move towards decentralised processes.
This move is partly enabled by the advances with smart devices and the rise of
the Internet-of-Things.
By increasing the use of smart sensors a manufacturer can better supervise the
operation of their equipment and, for example, better predict equipment failure.

// - Need for fast data processing
// search: large amounts of sensor data in industry
// REFS:
// Big Data Challenges and Opportunities in the Hype of Industry 4.0

As _Khan et al._ notes @khan, sensors and PLCs are becoming the largest group
of devices that generates the most data.
And as the industries scales up their sensor networks there's an increasing need
to be able to faster process the larger amounts of data,
in order to provide real-time analysis. 

// - introduce matrix profile

This bachelor thesis will explore the use of anomaly detection on time
series data, performed on hardware-limited devices closer to the Edge.
This is an attempt at evaluating the possible usefulness of running data analysis
directly on smart sensors.
The method of anomaly detection will revolve around the Matrix Profile,
as introduced by _Yeh et al._ @yeh,
which is a family of algorithms that can be used for detecting discord anomalies,
among other uses.
They also note that "time series discords are known to be very competitive as
novelty/anomaly detectors."

The Matrix Profile is a simple algorithm with claims of being easily scaleable
@yeh and as such might offer a more performant alternative to machine learning
models or other artificial intelligence solutions that are popular as of today.
#highlight[
And being a simple algorithm the Matrix Profile might also be able to run on
smaller devices and sensors, that have too little processing power required for
running heavier AI models.
]


== Motivation

// The background offers the background to why you are working with your problems.

// - Growing sensor networks and increasing amounts of data in the industry
// search: industry 4.0
// REFS:
// Industry 4.0

Today the world is experiencing it's fourth industrial revolution.
If the two previous revolutions were driven by the use of electricity and
digitisation in the manufacturing industry,
then today's shift is mainly driven by the large amount of smart, modular, and
highly connected devices that forms the so called Internet-of-Things.
Dubbed as "Industry 4.0" by the team of german scientists _Dr. Lasi et al._
@lasi,
this new revolution originated from the need of increased flexibility and better 
efficiency in production systems, in order to better handle quickly shifting
market demands.

_Dr. Lasi et al._ continues in their article with,
that today's manufacturing plants can be turned into "smart factories"
thanks to technology pushing towards miniaturisation, digitisation, and automation.
These factories are utilising a growing number of sensors and digital, decentralised
systems that allows the factories to become more autonomously monitored and
controlled remotely.

// - Benefits of sensor networks
// search: sensors industry 4.0
// REFS:
// Significance of sensors for industry 4.0: Roles, capabilities, and applications

_Javaid et al._ @javaid also notes an increasing need of intelligent sensor
systems and networks for the smart factories.
By using autonomous sensors with higher processing capabilities,
the industry will be able to reduce their dependency on human operators and thus
reduce problems caused by the human factor, for example. 
Another benefit can be realised in the maintenance of increasingly complex systems,
as more precise detection can send alerts sooner for any failing components and
thus reduce costly maintenance downtime during production.
And with wireless sensors, monitoring is made possible for inaccessible locations
such as remote or hazardous areas.

// - Challenges with sensor networks and noisy data
// search: costs required to operate larger sensor networks???
// REFS:
// Industrial Wireless Sensor Networks: Challenges, Design Principles, and
// Technical Approaches

Of course, with increasingly larger sensor networks it also follows that the
amount of data that needs to be processed increases, as mentioned by _Javaid_.
More raw data requires communication networks with higher processing capacity.
_Gungor et al._ @gungor suggests that the sensors should filter their data and
only send the processed data, as a step towards reducing the network overhead.
Doing so also has the possible benefit of reducing signal interference, delays,
and other anomalies that could be caused by faulty components or by the
environment's wear and tear that degrades the sensors over time.
In a later section, _Gungor_ continues with a simplified outline of a basic sensor
and notes that "... local data processing is crucial in minimizing power
consumption ...".
This has the potential of extending the lifetime of the sensors that runs on
battery, or similarly limited power sources, as well as reducing the operational
costs.

// - Application of anomaly detection to autodetect early warning signs
// search: anomaly detection temporal data
// REFS:
// Outlier Detection for Temporal Data: A Survey

Given that sensor readings are most often timestamped and thus temporal in nature
as stated by _Gupta et al._ @gupta,
then the data analysis should focus on ensuring the "temporal continuity" has
been maintained.
The analysis should flag any sudden anomalies or other kinds of observed outliers
in the time series data.


== Problem definition <definition>

This thesis looks to investigate and try to answer the following questions:

- Is it possible to run the matrix profile algorithm in a limited hardware
	environment, such as a small, of-the-shelf microprocessor board, and be able
	to detect anomalies in the data streams from multiple sensors?

- If so, how efficient would this on-device-detection be in terms of sent data
	traffic (or lack of) and energy use?
	The microprocessor board should have it's performance benchmarked against a
	similar board, but which sends all sensor data continuously to a remote
	controller instead.

Positive outcomes to these questions would then indicate that sensor analysis
done close to the Edge would be beneficial to the individual sensor's lifetime
and thus reduce the overall amount of spent resources required for operating
larger sensor networks.


== Delimitations

Due to the limited time available to write a bachelor thesis,
I have constrained this thesis to only analyse the application of the matrix
profile algorithm. 
#strike[
I also have limited experience with hardware development,
so I'll only use simple and naive methods for wireless data transfer and power
monitoring.
]


== Thesis structure

The rest of the thesis has it's structure organised in the following way.
@background introduces the theory and commonly used methods for anomaly detection.
@method walks through the implementation of the Matrix Profile algorithm and
how it's applied in the hardware.
Then the section continues with the collection of data from the hardware sensors. 
@results documents and analyses the results from the data collection,
which is then discussed --  in relation to the original problem definitions --
in @discussion.
// A final conclusion is then given in @conclusion, with suggestions for future work.


////////////////////////////////////////////////////////////////////////////////
// Theory

#pagebreak()
= Background and related work, ~7 pages <background>

// - anomaly detection intro
// REFS:
// @chandola Anomaly Detection: A Survey

Anomaly detection is a broad area that has been studied in great detail during
the last two decades @wang, @boniol.
But what is anomaly detection? _Chandola et al._ @chandola offers a definition:

#quote[
	Anomaly detection refers to the problem of ﬁnding patterns in data 
	that do not conform to expected behavior ...
	[which] translate to signiﬁcant, and often critical, actionable
	information in a wide variety of application domains.
]

Being able to find these non-conforming behaviours and patterns in all kinds of
data is very useful indeed.
Any applicable context that have some kind of continuously, periodic data readings
involved can benefit from anomaly monitoring and detection,
to prevent problems cropping up in the future.


== Applications and challenges

Let's illustrate with a few example applications that are commonly used in the
literature @chandola, @gupta:

- Network intrusion:
	A network and it's local resources such as servers, data repositories and even
	users, can have it's traffic monitored to prevent the unauthorised use of or
	access to critical components such as private data or administrator users.
	Common problems in this domain involves being able to handle the large amount
	of streaming data generated from, for example, data traffic that can cause
	false alarms.
	
- Fraud detection:
	Here the goal is to detect any criminal activities from users that are looking
	for ways to fraudulently collect any resources with economical benefits,
	from other users or companies such as banks and insurance agencies.
	For example, any excessive communication could be flagged as an anomaly and thus
	indicate possible insider trading within a company.
	
- Medical and public health monitors:
	Medical symptoms or diseases can be detected and tracked by using medical data,
	either from patient records or attached health sensors.
	For example, it's common to monitor a patient's condition over time
	or tracking the outbreak of diseases in specific areas such as cities.
	In this scenario, not being able to detect anomalies in the patient's data could
	have fatal results.

- Industrial damage monitoring and sensor networks:
	Monitoring the wear and tear on industrial equipment allows for taking preventive
	action that can minimise the costs of service interruptions or equipment failures.
	Most often this requires running analysis on online, streaming data from sensor
	networks, for example, in order to detect the anomalies in a quicker manner.

// Challenges with anomaly detection

But detecting non-conforming patterns in data is a difficult problem.
_Chandola_ have also noted a set of challenges associated with classifying any
observed patterns:

- It's hard to distinguish noise in the data from true anomalies, as they can
	show similar-looking patterns.
- It's hard to draw a clear boundary between what's a normal or anomalous pattern,
	while covering all possible normal cases.
- A set of patterns considered as normal behaviour at the present time can fail
	to cover any future patterns, due to evolving conditions.
- Different application domains have different anomalous patterns and thus it's
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
k-nearest neighbor (a distance based model), 
DBSCAN (a clustering model),
or any mix of multiple models.
But these models have shared problems of requiring extensive training data before
being able to run data analysis, which might require human supervision.
The models could also be too computation heavy for running in
resource-constrained environments, such as small devices and sensors.


== Types of anomalies

// - types of anomalies
// REFS:
// Revisiting Time Series Outlier Detection: Deﬁnitions and Benchmarks

Yet another challenge is how to define what is an anomalous pattern.
Most often it's some kind of outlier that clearly differentiates itself from
the other data, but it could also be more subtle issues that's harder to spot.
A definition that is commonly used in the literature @chandola, @gupta
and summarised by _Lai et al._ @lai:

- Point anomalies:
	Individual data points with extreme values that make them stand out
	from all other points in the data.
	These are the most simplest to detect and have been the largest focus in
	previous research.

- Contextual anomalies:
	These are also individual data points, but with values that make them stand out
	in the local context --
	which needs to be defined during the analysis --
	instead of globally.
	It's considered a harder problem to identify this kind of anomaly.

- Collective anomalies:
	This is a subsequence of data points, which individually might not stand out
	but as a group they could differentiate themselves from the rest of the data,
	globally.

// - define discord anomalies

_Lai_ illustrated these anomalies nicely in @anomalies, shown below. 
To save time, this thesis will be limited to a group of collective anomalies
referred to as *discords*, which _Yeh et al._ @yeh defines as "the subsequence
that has the maximum distance to its nearest neighbor."

#figure(
	image("images/standard_anomalies.png"),
	caption: [
		Examples of anomalies in time series data. \
		Left = point, middle = contextual, right = collective.
	]
) <anomalies>


== Detecting discord anomalies

// - discord detection using MP

Discord anomalies can be detected by using the novel method introduced by _Yeh_
in @yeh, which they call the Matrix Profile.
A Matrix Profile is a form of metadata array

// - the DAMP algo, an alternative to MP
// - helper func backwardProcess
// - helper func MASS v2, nearest neighbour search


////////////////////////////////////////////////////////////////////////////////
// Method

#pagebreak()
= Method, ~8 pages <method>

// The implementation describes how you have implemented a solution to your problems.

// - citations-00060-Matrix Profile XXIV_ Scaling Time Series Anomaly Detection_to Trillions of Datapoints and Ultra-fast Arriving Data Streams.pdf
// 	DAMP algo, fast/high scale, complexity, learning warning threshold
// 	use in: theory, method
//
// - citations-00006-Anomaly Detection on IT Operation Series_via Online Matrix Profile.pdf
// 	detailed cache optimisation for MP, complexity and problems with normalisation, positive results
// 	use in: theory, method
//
// - need references for HW, wireless transfer, power monitoring, data logging

TODO

- example plot from matlab

- DAMP algo details
- verifying implementation against references
- caching?
- handling normalisation issues?
- hardware setup
- collecting sensor data
- wireless
- power monitoring
- cache optimisation?
- problems with normalisation?

////////////////////////////////////////////////////////////////////////////////
// Results

// The evaluation evaluates whether you have actually solved your problems.

#pagebreak()
= Results, ~10 pages <results>

TODO

== Analysis

TODO

////////////////////////////////////////////////////////////////////////////////
// Discussion

// The discussion discusses each individual problem, how you addressed it, alternative solutions and shortcomings, etc.

#pagebreak()
= Discussion <discussion>

TODO

hard to work with matlab code examples:
- one-based indexing (instead of the more common zero indexing) causing many issues
	and off-by-one errors.
- large amount of helper funcs required for performing arithmetic on arrays.
- doing a fast fourier transform required the use of complex numbers, which was
	a completely different type in Go and might cause performance problems.

////////////////////////////////////////////////////////////////////////////////
// Conclusion

// The conclusions and future work describes the final outcome of how you solved your problems and what is left to do.

== Conclusion

TODO

== Future work

TODO

////////////////////////////////////////////////////////////////////////////////
// References

#pagebreak()
= References

#bibliography(
	"references.yml",
	style: "ieee",
	title: none,
)

////////////////////////////////////////////////////////////////////////////////
// Appendices

#pagebreak()
= Appendix A

TODO matlab code and appendix b the prototype?

