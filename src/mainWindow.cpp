#include "mainWindow.h"


MainWindow::MainWindow(QWidget* parent, Qt::WindowFlags flags)
	: QMainWindow{ parent, flags }
	, centralWidget{ new QWidget{ this } }
{
	setCentralWidget(centralWidget);
}
