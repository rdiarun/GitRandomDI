using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace DetectorInspector.ViewModels
{
	public abstract class ViewModel
	{
		protected void UpdateCollection<TViewModel, TModel>(
			ICollection<TViewModel> viewCollection,
			ICollection<TModel> modelCollection,
			Func<TViewModel, TModel, bool> areEqual,
			Action<TViewModel> addAction,
			Func<TViewModel, TModel, bool> updateAction,
			Action<TModel> removeAction)

			where TViewModel : class
			where TModel : class
		{
			var removals = new List<TModel>();

			// cater for the removals first.
			foreach (var modelItem in modelCollection)
			{
				if (viewCollection.Count == 0)
				{
					removals.Add(modelItem);
				}
				else
				{
					TViewModel matchedItem = null;

					foreach (var viewItem in viewCollection)
					{
						if (areEqual(viewItem, modelItem))
						{
							matchedItem = viewItem;
							break;
						}
					}

					if (matchedItem == null)
					{
						// save the items to be removed into another collection as we
						// can't modify the collection we are currently iterating over.
						removals.Add(modelItem);
					}
					else if (updateAction != null)
					{
						if (updateAction(matchedItem, modelItem))
						{
							removals.Add(modelItem);
						}
					}
				}
			}

			foreach (var removedItem in removals)
			{
				removeAction(removedItem);
			}

			// cater for the additions.
			foreach (var viewItem in viewCollection)
			{
				bool isMatched = false;

				foreach (var modelItem in modelCollection)
				{
					if (areEqual(viewItem, modelItem))
					{
						isMatched = true;
						break;
					}
				}

				if (!isMatched)
				{
					addAction(viewItem);
				}
			}
		}

	}
}
