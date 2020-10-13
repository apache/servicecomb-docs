import setuptools

setuptools.setup(
    name="mkdocs-bingsearch",
    version="0.0.1",
    packages=['mkdocs_bingsearch'],
    package_data={'mkdocs_bingsearch': ['search/main.js']},
    entry_points={
        'mkdocs.plugins': [
            'bingsearch = mkdocs_bingsearch:SearchPlugin'
        ]
    }
)
