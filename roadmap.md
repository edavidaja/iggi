# roadmap

project goal: semantic-aware full-text search of all GAO reports issued since 1974 

problem: most of these reports are only published in pdf form, with minimally available web metadata

base deliverable: clean, strucutred, full-text of reports

## data

- bulk initial download of GAO and other IG reports
  	- No IGs expose any APIs for systematic report download, meaning that some crawling of web pages will be necessary
- build a process for keeping database of publications up to date

### notes

- text should be tagged by report section?
- parse footnotes
- parse tables: https://frictionlessdata.io/specs/table-schema/
- citation graph
- ocr agency responses
- flattening the text before titles are extracted will result in garbage on lines

## 