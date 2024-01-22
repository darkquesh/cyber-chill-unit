import matplotlib.pyplot as plt
from sklearn.metrics import confusion_matrix, ConfusionMatrixDisplay
from sklearn.svm import SVC
import numpy as np
from mlxtend.plotting import plot_confusion_matrix

y_true = np.array([[56, 0, 0, 0],   # apple
                   [0, 24, 0, 0],   # orange
                   [73, 5, 1, 0],   # peach
                   [41, 2, 0, 21]]) # pear

y_pred = np.array([[56, 0, 73, 41], # apple
                   [0, 24, 5, 2],   # orange
                   [0, 0, 1, 0],    # peach
                   [0, 0, 0, 21]])  # pear

cm = np.array([[56, 0, 0, 0], # apple
               [0, 24, 0, 0],   # orange
               [73, 5, 1, 0],    # peach
               [41, 2, 0, 21]])  # pear

labels=["apple", "orange", "peach", "pear"]


titles_options = [
    ("Confusion matrix, without normalization", False),
    ("Normalized confusion matrix", True),
]

for title, normalize in titles_options:
    fig, ax = plot_confusion_matrix(conf_mat = cm,
                                    class_names = labels,
                                    show_absolute = not normalize,
                                    show_normed = normalize,
                                    colorbar = True)
    
    fig.text(s=title, x=0.5, y=0.95, fontsize=12, ha='center', va='center')
    fig.text(s="Model: Detic_LCOCOI21k_CLIP_SwinB_896b32_4x_ft4x_max-size", 
             x=0.5, y=0.90, fontsize=8, ha='center', va='center')

plt.autoscale()
plt.show()

y_true = []

y_pred = []

labels=["apple", "orange", "peach", "pear"]

cm = confusion_matrix(y_true, y_pred, labels=labels)

disp = ConfusionMatrixDisplay(confusion_matrix=cm, display_labels=labels)
disp.plot()
plt.show()


#disp = ConfusionMatrixDisplay(confusion_matrix=cm, display_labels=labels)
#disp.plot()
