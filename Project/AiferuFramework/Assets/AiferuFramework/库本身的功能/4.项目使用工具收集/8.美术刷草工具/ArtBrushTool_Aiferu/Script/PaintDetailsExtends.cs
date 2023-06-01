#if UNITY_EDITOR
using System;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
using static UnityEditor.ShaderGraph.Internal.KeywordDependentCollection;
using static UnityEngine.Experimental.TerrainAPI.TerrainUtility;

namespace AiferuFramework.ArtBrushTool
{
    [InitializeOnLoad]
    public class PaintDetailsEXtends
    {
        private static int layerMask =0;
        #region �󶨳���GUI��Ⱦ�ص�
        static PaintDetailsEXtends()
        {
            //�󶨳���GUI��Ⱦ��
            SceneView.duringSceneGui += OnSceneGUI;
        }

        //~PaintDetailsEXtends()
        //{
        //    SceneView.duringSceneGui -= OnSceneGUI;
        //}
        #endregion

        //Scene���ص�����
        static void OnSceneGUI(SceneView view)
        {
            if (ArtBrushToolEW.ins == null)
                return;
            //�ж��Ƿ���������ˢ�ݹ���
            if (ArtBrushToolEW.ins.Enable)
            {
                Planting();
            }
        }


        static void Planting()
        {
            //ʹ������ȡ���潻��
            Event e = Event.current;
            //�����������ʱ
            RaycastHit raycastHit = new RaycastHit();
            Ray terrainRay = HandleUtility.GUIPointToWorldRay(e.mousePosition);
            //Debug.DrawLine(terrainRay.origin, terrainRay.GetPoint(100), Color.red);
            if (Physics.Raycast(terrainRay, out raycastHit, Mathf.Infinity))
            {
                //������껮��λ�úͱ༭��������õ��ܶȵȲ���ʵ����ֲ�� �����ϱ��
                //ʵ����ֲ��
                if (e.type == EventType.MouseDown && e.button == 0 && ArtBrushToolEW.ins.BrushEnable)
                {
                    if (ArtBrushToolEW.ins.data.BrushIsAddMode)
                    {
                        //���ģʽ
                        AddBrush(raycastHit);
                    }else
                    {
                        //ɾ��ģʽ
                        SubBrush(raycastHit);
                    }

                }
            }
            //���Ʊ�ˢ
            DrawBrush(raycastHit);
        }

        /// <summary>
        /// ɾ����ˢ
        /// </summary>
        private static void SubBrush(RaycastHit hit)
        {
            //��������
            for (int i = 0; i < ArtBrushToolEW.ins.data.Density * ArtBrushToolEW.ins.data.BrushSize; i++)
            {
                Vector2 randomPoint = UnityEngine.Random.insideUnitCircle * (ArtBrushToolEW.ins.data.BrushSize / 2);
                Vector3 randomPoint3 = new Vector3(randomPoint.x, 0, randomPoint.y) + hit.point;
                Ray ray = new Ray(randomPoint3, hit.normal);
                Handles.DrawLine(randomPoint3, randomPoint3 + (hit.normal * ArtBrushToolEW.ins.data.BrushSize / 2));
                Debug.Log(randomPoint3);
            }
        }

        /// <summary>
        /// ��ӱ�ˢ
        /// </summary>
        private static void AddBrush(RaycastHit hit)
        {
            //��������
            for (int i = 0; i < ArtBrushToolEW.ins.data.Density * ArtBrushToolEW.ins.data.BrushSize; i++)
            {
                //������������
                Vector2 randomPoint = UnityEngine.Random.insideUnitCircle * (ArtBrushToolEW.ins.data.BrushSize / 2);
                Vector3 randomPoint3 = new Vector3(randomPoint.x, 0, randomPoint.y);

                //�Ʒ�������ת����
                //���㷨����������y�����ת
                Quaternion rotation = Quaternion.FromToRotation(Vector3.up,hit.normal);
                Vector3 newPos = rotation* randomPoint3+hit.point;

                Ray ray = new Ray(newPos + hit.normal*Mathf.Clamp(ArtBrushToolEW.ins.data.BrushSize/36,0.1f,10f), -hit.normal);

                RaycastHit targetHit = new RaycastHit();

                Physics.Raycast(ray, out targetHit, Mathf.Infinity);
                Debug.DrawRay(ray.origin, ray.direction, Color.blue, 1f);
                Debug.Log(randomPoint3);
                Debug.Log(targetHit.point);
                InsProfab(targetHit);
            }

            
        }

        private static void InsProfab(RaycastHit hit)
        {
            GameObject target = ArtBrushToolEW.ins.data.Plants[ArtBrushToolEW.ins.data.PlantSelect];
            if (target == null) return;
            GameObject go = PrefabUtility.InstantiatePrefab(target) as GameObject;
            go.transform.position = hit.point;
            go.transform.up = hit.normal;
            float scale = UnityEngine.Random.Range(ArtBrushToolEW.ins.data.ScaleRandomMin, ArtBrushToolEW.ins.data.ScaleRandomMax);
            go.transform.localScale = go.transform.localScale * scale;
        }

        /// <summary>
        /// ���Ʊ�ˢ
        /// </summary>
        private static void DrawBrush(RaycastHit hit)
        {
            if (ArtBrushToolEW.ins.BrushEnable)
            {
                //���ñ༭ģʽΪ��,����ˢ��ˢ��ʱ����޷�ʹ���ƶ���ת��
                Tools.current = Tool.None;
                //����Ĭ�ϵ�ѡ��,�����Ͳ���ѡ������
                HandleUtility.AddDefaultControl(GUIUtility.GetControlID(FocusType.Passive));

                //���Ʊ�ˢ��ʽ
                Handles.color = new Color(1,1,1,0.1f);
                Handles.DrawSolidDisc(hit.point, hit.normal, ArtBrushToolEW.ins.data.BrushSize/2);
                Handles.color = Color.red;
                Handles.DrawWireDisc(hit.point, hit.normal, ArtBrushToolEW.ins.data.BrushSize/2);
                Handles.DrawLine(hit.point, hit.point+(hit.normal* ArtBrushToolEW.ins.data.BrushSize / 2));




            }

        }
    }
}
#endif
