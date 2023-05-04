//
//  CameraFollowsInTheScene.cs
//  AiferuFramework
//
//  Created by Aiferu on 2023/5/4.
//
//
#if UNITY_EDITOR
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using UnityEngine.PlayerLoop;

namespace AiferuFramework
{
    /// <summary>
    /// Scene�����������
    /// </summary>
    public class CameraFollowsInTheScene 
    {
        #region Field

        #endregion

        #region Property

        #endregion

        #region UnityOriginalEvent
        

        static CameraFollowsInTheScene()
        {
            SceneView.duringSceneGui += view =>
            {
                if (Event.current.type == EventType.KeyDown)
                {
                    if (Event.current.keyCode == KeyCode.Space)
                    {
                        Debug.Log("�ո���");
                    }
                }
            };
        }
        #endregion

        #region Function

        #endregion
    }
}
#endif