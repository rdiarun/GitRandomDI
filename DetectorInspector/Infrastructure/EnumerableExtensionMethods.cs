using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.ComponentModel;
using System.Linq.Expressions;
using System.Reflection;

namespace DetectorInspector.Infrastructure
{
    public static class EnumerableExtensionMethods
    {
        public static IEnumerable<T> GetPage<T>(this IEnumerable<T> items, int pageNumber, int pageSize, string sortBy, ListSortDirection sortDirection, out int itemCount, out int pageCount)
        {
            if (pageSize < 1)
            {
                throw new ArgumentOutOfRangeException("pageSize");
            }

            itemCount = items.Count();
            pageCount = (int)Math.Ceiling((float)itemCount / (float)pageSize);

            if (pageNumber < 0)
            {
                throw new ArgumentOutOfRangeException("pageNumber");
            }

            if (sortBy != string.Empty)
            {
                items = items.OrderBy(sortDirection, sortBy);
            }

            var firstResult = (pageNumber - 1) * pageSize;

            return items.Skip(firstResult - 1).Take(pageSize);
        }

        public static IEnumerable<T> OrderBy<T>(this IEnumerable<T> source, ListSortDirection order, string property)
        {
            if (order == ListSortDirection.Ascending)
            {
                return ApplyOrder<T>(source, property, "OrderBy");
            }

            return ApplyOrder<T>(source, property, "OrderByDescending");
        }

        private static IEnumerable<T> ApplyOrder<T>(IEnumerable<T> source, string property, string methodName)
        {
            var props = property.Split('.');

            var type = typeof(T);

            ParameterExpression arg = Expression.Parameter(type, "x");

            Expression expr = arg;

            foreach (string prop in props)
            {
                var pi = type.GetProperty(prop);

                expr = Expression.Property(expr, pi);
                type = pi.PropertyType;
            }

            var delegateType = typeof(Func<,>).MakeGenericType(typeof(T), type);

            var lambda = Expression.Lambda(delegateType, expr, arg);

            var result = typeof(Enumerable).GetMethods().Single(
                    method => method.Name == methodName
                            && method.IsGenericMethodDefinition
                            && method.GetGenericArguments().Length == 2
                            && method.GetParameters().Length == 2)
                    .MakeGenericMethod(typeof(T), type)
                    .Invoke(null, new object[] { source, lambda.Compile() });

            return (IEnumerable<T>)result;
        }

    }
}
