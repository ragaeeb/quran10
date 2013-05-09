#ifndef LOGGER_H_
#define LOGGER_H_

#define DEBUG 1
//#define TEST 1

#ifdef DEBUG
#include <QDebug>

#define LOGGER(a) qDebug() << __TIME__ << __FILE__ << __LINE__ << __FUNCTION__ << a;
#else
#define LOGGER(a)
#endif

#endif /* LOGGER_H_ */
