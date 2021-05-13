# Quantifying the financial impact of UK Generic Pharmaceutical Shortages 

![*Showing the cumulative financial effect of generic pharmaceutical shortages since 2015, totalling almost £2.5 billion.*](https://analytichealth.co.uk/wp-content/uploads/2021/03/shortages.png)

This R-Shiny application was developed to quantify the financial impact of generic pharmaceutical shortages in the United Kingdom. Generic pharmaceutical shortages have a large impact on the National Health Service (NHS) finances. During a shortage event the Department of Health and Social Care (DHSC) issue an amendment to the original reimbursement price (or drug tariff price), in what is known as the concessionary price. Each month, an average of 24 active ingredients experience a supply shortage, putting patient's health at risk and also adding to the financial burden of the National Health Service (NHS). 

During a supply shortage event, the NHS reimburse pharmacies at a higher rate for the drug, aiming to compensate the pharmacies for their additional spending on the higher-priced branded pharmaceutical alternatives. 

We built a model in R which generates an estimation of the NHS spending had there not been a supply shortage at all and compared this against the actual spending amount. The results are staggering, **since 2015 the top 100 active ingredients alone have contributed to £1.7 billion (USD2.4 billion) additional spending. The full amount including all active ingredients is over £2.5 billion (USD3.5 billion)**. This amount continues to compound over time because the drug prices remain elevated for months and often years after the shortage event. 

By developing this application we want to raise awareness of the impact of shortage events in the pharmaceutical supply chain. And with the knowledge we gather we can actively act upon preventing these situations by predicting shortage events and mitigate the financial impact.

## About the data

The data used in this application originates from [PSCN]('https://psnc.org.uk/dispensing-supply/supply-chain/generic-shortages/') and the [NHS]('https://opendata.nhsbsa.net/dataset/english-prescribing-data-epd'). We gather data on prescribing quantities and generic shortages on a monthly basis.  

## About the authors

This application was built by:

* 👨‍💻  [Greg Mills]('https://github.com/analytichealth') (Managing Director and Founder at Analytic Health)
* 👩‍💻 [Veerle van Leemput]('https://github.com/hypebright') (Managing Director and Head of Data Science at Analytic Health)

Our mission is to accelerate innovation in healthcare by developing artificial intelligence technology. Gathering data and being able to analyze that data play a vital role in achieving this mission. 

## Live application

This repo was used to submit our entry for the [Shiny Contest 2021]('https://blog.rstudio.com/2021/03/11/time-to-shiny/'). This repo contains a static dataset. To see our live version in action you can visit [this page]('https://apps.analytichealth.co.uk/shortages/'). 

## More information

We wrote a blog about this application [here]('https://analytichealth.co.uk/quantifying-the-financial-impact-of-uk-generic-pharmaceutical-shortages/'), where you can read more about the issue or contact us to discuss it further 💬 .
